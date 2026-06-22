#!/usr/bin/env bash
#
# ghq-migrate.sh
#
# 既存のローカル git リポジトリ群を ghq 管理下（$GHQ_ROOT/<host>/<owner>/<repo>）へ
# "ディレクトリ移動" で取り込むスクリプト。
#
# WHY: 再 clone ではなく mv にすることで、Private リポジトリでも認証なしに確実に移行でき、
#      未コミット変更・ローカルブランチ・stash・untracked ファイルを全て保持できる。
#      ghq は配置パスだけで管理判定するため、正しい場所へ移動するだけで管理下に入る。
#
# Usage:
#   ghq-migrate.sh [options] [SRC_DIR ...]
#
# Options:
#   -d, --dest DIR   移行先 ghq root（デフォルト: $(ghq root) → 既定 ~/ghq）
#   -n, --dry-run    計画の表示のみ。実際の移動は行わない
#   -y, --yes        確認プロンプトをスキップして実行
#   -h, --help       このヘルプを表示
#
# Examples:
#   ghq-migrate.sh                         # ~/personalDev ~/vcl を ghq root へ
#   ghq-migrate.sh ~/work ~/oss            # 任意の移行元を指定
#   ghq-migrate.sh -d ~/ghq ~/personalDev  # 移行先を明示
#   ghq-migrate.sh --dry-run               # まず計画だけ確認

set -euo pipefail

# ---- defaults ---------------------------------------------------------------
DEFAULT_SOURCES=("$HOME/personalDev" "$HOME/vcl")
DEST=""
DRY_RUN=0
ASSUME_YES=0
SOURCES=()

# ---- pretty output ----------------------------------------------------------
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'; C_DIM=$'\033[2m'; C_BLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_DIM=""; C_BLD=""; C_RST=""
fi
info()  { printf '%s\n' "${C_BLU}==>${C_RST} $*"; }
ok()    { printf '%s\n' "${C_GRN}✔${C_RST} $*"; }
warn()  { printf '%s\n' "${C_YEL}!${C_RST} $*" >&2; }
err()   { printf '%s\n' "${C_RED}✖${C_RST} $*" >&2; }

die() { err "$*"; exit 1; }

usage() {
  sed -n '2,40p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'
  exit "${1:-0}"
}

# ---- requirement checks -----------------------------------------------------
check_requirements() {
  local missing=0

  if ! command -v git >/dev/null 2>&1; then
    err "git が見つかりません。"
    printf '   %s\n' "${C_DIM}インストール: https://git-scm.com/  (macOS: xcode-select --install / brew install git)${C_RST}"
    missing=1
  fi

  if ! command -v ghq >/dev/null 2>&1; then
    err "ghq が見つかりません。"
    printf '   %s\n' "${C_DIM}インストール: brew install ghq  /  go install github.com/x-motemen/ghq@latest${C_RST}"
    missing=1
  fi

  if ! command -v gh >/dev/null 2>&1; then
    err "gh (GitHub CLI) が見つかりません。"
    printf '   %s\n' "${C_DIM}インストール: brew install gh  /  https://cli.github.com/${C_RST}"
    missing=1
  fi

  if ! command -v fd >/dev/null 2>&1; then
    err "fd が見つかりません。"
    printf '   %s\n' "${C_DIM}インストール: brew install fd  /  cargo install fd-find  (Debian: apt install fd-find → fdfind)${C_RST}"
    missing=1
  fi

  [[ $missing -eq 0 ]] || die "必要なコマンドが不足しています。上記をインストールしてから再実行してください。"

  # gh 認証チェック（Private リポジトリの remote 検証に必要）
  if ! gh auth status >/dev/null 2>&1; then
    err "GitHub CLI が未認証です。"
    printf '   %s\n' "${C_DIM}次を実行してログインしてください: gh auth login${C_RST}"
    die "認証が完了してから再実行してください。"
  fi

  ok "要件チェック OK (git / ghq / gh / fd / gh auth)"
}

# ---- arg parsing ------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dest)    DEST="${2:?--dest にはディレクトリを指定してください}"; shift 2 ;;
      -n|--dry-run) DRY_RUN=1; shift ;;
      -y|--yes)     ASSUME_YES=1; shift ;;
      -h|--help)    usage 0 ;;
      --)           shift; while [[ $# -gt 0 ]]; do SOURCES+=("$1"); shift; done ;;
      -*)           err "不明なオプション: $1"; usage 1 ;;
      *)            SOURCES+=("$1"); shift ;;
    esac
  done

  [[ ${#SOURCES[@]} -gt 0 ]] || SOURCES=("${DEFAULT_SOURCES[@]}")
  [[ -n "$DEST" ]] || DEST="$(ghq root)"
}

# ---- url -> host/owner/repo -------------------------------------------------
# 対応: git@host:owner/repo(.git) / ssh://git@host[:port]/owner/repo(.git)
#       https://host/owner/repo(.git) / http://... / host/owner/repo
remote_to_path() {
  local url="$1" path host rest
  url="${url%/}"
  url="${url%.git}"
  case "$url" in
    *://*) path="${url#*://}"; path="${path#*@}" ;;  # scheme と user@ を除去
    *@*)   path="${url#*@}" ;;                        # scp形式: user@ を除去
    *)     path="$url" ;;
  esac
  # この時点で path は host:owner/repo / host:port/owner/repo / host/owner/repo のいずれか
  if [[ "$path" == *:* ]]; then
    host="${path%%:*}"
    rest="${path#*:}"
    [[ "$rest" =~ ^[0-9]+/ ]] && rest="${rest#*/}"  # ssh URL の host:port のポートを除去
    path="$host/$rest"
  fi
  printf '%s\n' "$path"
}

# ---- repo discovery + metadata (並列) ---------------------------------------
# 各 .git のリポジトリルートを探し、remote URL と dirty 判定をまとめて TSV で出力する。
#   出力: <repo-path>\t<remote-url>\t<dirty 0|1>
# WHY(探索): find は node_modules 等の巨大ツリーまで総なめして遅い。fd は .gitignore を
#   尊重して枝刈りし並列探索するため大幅に高速（実測 ~6x）。--prune で .git 内部にも潜らない。
# WHY(並列): リポジトリ毎の git 呼び出し(remote 取得 + status)が逐次だと数百プロセス分の
#   起動コストで詰まる。fd の --exec はコア数ぶん並列実行するのでここを一括短縮できる。
#   ({//} は .git の親 = リポジトリルート)
collect_repo_meta() {
  local src="$1"
  fd --hidden --prune --type directory --absolute-path '^\.git$' "$src" 2>/dev/null \
    --exec bash -c '
      repo="$1"
      url="$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
      if [ -z "$url" ]; then
        r="$(git -C "$repo" remote 2>/dev/null | head -n1)"
        [ -n "$r" ] && url="$(git -C "$repo" remote get-url "$r" 2>/dev/null || true)"
      fi
      dirty=0
      [ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ] && dirty=1
      # WHY: 空フィールドがあると IFS=tab の read で連続タブが潰れて列がずれるため、
      #      remote 無しは "-" センチネルで埋める。
      [ -z "$url" ] && url="-"
      printf "%s\t%s\t%s\n" "$repo" "$url" "$dirty"
    ' _ {//}
}

# ---- main -------------------------------------------------------------------
main() {
  parse_args "$@"
  check_requirements

  mkdir -p "$DEST"
  local dest_abs; dest_abs="$(cd "$DEST" && pwd -P)"
  info "移行先 (ghq root): ${C_BLD}${DEST}${C_RST}"
  info "移行元: ${C_BLD}${SOURCES[*]}${C_RST}"

  # 移行先が移行元の内側/同一だと配置が入れ子になり分かりにくいので警告
  local s s_abs
  for s in "${SOURCES[@]}"; do
    [[ -d "$s" ]] || continue
    s_abs="$(cd "$s" && pwd -P)"
    if [[ "$dest_abs" == "$s_abs" || "$dest_abs" == "$s_abs"/* ]]; then
      warn "移行先 ($DEST) が移行元 ($s) の内側/同一です。"
      warn "  ghq root を別ディレクトリ(例 ~/ghq)にして実行することを推奨します。"
      warn "  例: home.nix の ghq.root を ~/ghq にして home-manager switch、または -d ~/ghq を指定。"
    fi
  done

  [[ $DRY_RUN -eq 1 ]] && warn "DRY-RUN モード: 実際の移動は行いません"
  echo

  # 計画を組み立てる（plan_src / plan_dst を行単位で蓄積）
  local plans_src=() plans_dst=() plans_note=()
  local n_move=0 n_skip=0

  # 移行元ごとに git メタデータを並列収集し、TSV を結合・整列（決定的な重複判定のため）。
  local src
  local meta=""
  for src in "${SOURCES[@]}"; do
    if [[ ! -d "$src" ]]; then
      warn "移行元が存在しません（スキップ）: $src"
      continue
    fi
    meta+="$(collect_repo_meta "$src")"$'\n'
  done

  local repo url dirty relpath target note
  while IFS=$'\t' read -r repo url dirty; do
    [[ -n "$repo" ]] || continue

    if [[ -z "$url" || "$url" == "-" ]]; then
      warn "remote が無いため配置先を決められません（スキップ）: $repo"
      ((n_skip++)) || true
      continue
    fi

    relpath="$(remote_to_path "$url")"
    if [[ "$relpath" != */*/* ]]; then
      warn "remote URL を解釈できません（スキップ）: $repo  [$url]"
      ((n_skip++)) || true
      continue
    fi
    target="$DEST/$relpath"

    note=""
    [[ "$dirty" == "1" ]] && note="${C_YEL}未コミット変更あり(保持されます)${C_RST}"

    if [[ "$repo" -ef "$target" ]]; then
      info "既に正しい場所にあります（スキップ）: $repo"
      ((n_skip++)) || true
      continue
    fi
    if [[ -e "$target" ]]; then
      warn "移動先が既に存在（スキップ）: $target"
      ((n_skip++)) || true
      continue
    fi

    # 同一 remote を指す複製クローン（例: zeimeex / 2-zeimeex）が同じ移動先に衝突しないか
    local dup="" pd
    for pd in "${plans_dst[@]:-}"; do
      if [[ "$pd" == "$target" ]]; then dup=1; break; fi
    done
    if [[ -n "$dup" ]]; then
      warn "移動先が他リポジトリと衝突（スキップ。手動で確認してください）: $repo"
      warn "  -> $target は既に別のローカルクローンが使用予定です。"
      ((n_skip++)) || true
      continue
    fi

    plans_src+=("$repo")
    plans_dst+=("$target")
    plans_note+=("$note")
    ((n_move++)) || true
  done < <(printf '%s' "$meta" | sort)

  # 計画表示
  echo "${C_BLD}== 移行計画 ==${C_RST}"
  if [[ $n_move -eq 0 ]]; then
    ok "移動対象はありません。"
    exit 0
  fi
  local i
  for i in "${!plans_src[@]}"; do
    printf '  %s\n' "${plans_src[$i]}"
    printf "    ${C_DIM}->${C_RST} %s  %s\n" "${plans_dst[$i]}" "${plans_note[$i]}"
  done
  echo
  info "移動: ${C_BLD}${n_move}${C_RST} 件 / スキップ: ${n_skip} 件"

  if [[ $DRY_RUN -eq 1 ]]; then
    warn "DRY-RUN のため実行しません。実行するには --dry-run を外してください。"
    exit 0
  fi

  # 確認プロンプト
  if [[ $ASSUME_YES -ne 1 ]]; then
    echo
    printf '%s' "${C_BLD}上記 ${n_move} 件を移動します。よろしいですか? [y/N]: ${C_RST}"
    local ans=""
    read -r ans </dev/tty || true
    case "$ans" in
      y|Y|yes|YES) ;;
      *) die "中止しました。" ;;
    esac
  fi

  # 実行
  echo
  local moved=0
  for i in "${!plans_src[@]}"; do
    mkdir -p "$(dirname "${plans_dst[$i]}")"
    if mv "${plans_src[$i]}" "${plans_dst[$i]}"; then
      ok "moved: ${plans_dst[$i]}"
      ((moved++)) || true
    else
      err "移動失敗: ${plans_src[$i]}"
    fi
  done

  echo
  ok "完了: ${moved}/${n_move} 件を移動しました。"
  info "確認: ${C_DIM}ghq list${C_RST}"
}

main "$@"
