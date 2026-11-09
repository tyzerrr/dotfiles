# dotfiles

[English](README.md) | 日本語

`~/dotfiles` に clone し、nix-darwin + home-manager で `~/.config` などへ配置する macOS 用の dotfiles。

Neovim (Lua) のように Nix 化しないものも、配置は home-manager が行う。

- [構成](#構成)
- [適用のしかた](#適用のしかた)
  - [新しい Mac にセットアップする](#新しい-mac-にセットアップする)
  - [~/.config から移行する](#config-から移行する)
  - [適用後の確認](#適用後の確認)
- [日常の操作](#日常の操作)
- [設定の追加・変更](#設定の追加変更)
- [トラブルシューティング](#トラブルシューティング)
- [CI](#ci)

## 構成

```text
nix/
  flake.nix          nix-darwin + home-manager の flake (profile = OS ユーザー名)
  darwin.nix         全マシン共通の nix-darwin 設定 (Homebrew, launchd agent)
  hosts/<user>.nix   マシン固有の nix-darwin 設定 (追加の Homebrew, system.defaults)
  home.nix           home-manager のエントリポイントとパッケージ一覧
  home/              ツールごとの home-manager モジュール
  pkgs/ overlays/    自作パッケージ
  Makefile           適用・ビルド・ロールバック用のコマンド
nvim/ kitty/ wezterm/ sketchybar/ ...   Nix 化しない設定の実体
```

profile は OS ユーザー名で、`araki` は personal、`t-b-araki` は work 用。

各設定の扱いは次の3通り。

| 扱い | 対象 | 編集後の反映 |
| --- | --- | --- |
| Nix で生成 | zsh, oh-my-posh, git, tmux, ghostty, aerospace, gwq, cmux, borders, helm, homebrew の trust リスト, macOS defaults | `make switch` |
| store にコピーして配置 | sketchybar, wezterm, Claude Code の agents/commands/skills, tmux / omniwm の補助スクリプト | `make switch` |
| repo を直接リンク (`mkOutOfStoreSymlink`) | nvim, karabiner, kitty, omniwm の settings.toml, Claude Code の settings.json / mcp.json / CLAUDE.md | 即時 (アプリ自身も書き換えるため) |

直接リンクしているものは `~/dotfiles` 内のファイルそのものなので、アプリが書き換えた差分は `git diff` に出る。

## 適用のしかた

### 新しい Mac にセットアップする

1. Determinate Nix Installer で Nix を入れる。

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   nix-darwin 側は `nix.enable = false` にしていて、Nix daemon や `/etc/nix/nix.conf` は Determinate Nix Installer に任せている。

2. Homebrew を入れる: <https://brew.sh>

   nixpkgs に無いもの (`ghostty`, `mactex`, `sf-symbols`, `socket_vmnet` など) は `nix/darwin.nix` と `nix/hosts/<user>.nix` で宣言した Homebrew で入れる。

3. `~/dotfiles` に clone する。clone 先は `~/dotfiles` 固定 (`nix/flake.nix` の `dotfilesDirOf`)。

   ```sh
   git clone git@github.com:tyzerrr/dotfiles.git ~/dotfiles
   ```

4. 適用する。profile はデフォルトで現在の OS ユーザー名 (`$USER`)。sudo のパスワードを聞かれる。

   ```sh
   cd ~/dotfiles/nix
   make switch                    # 現在のユーザー名の profile
   make switch PROFILE=t-b-araki  # profile を指定する場合
   ```

5. 新しいターミナルを開く (zsh の設定は新しいシェルから有効になる)。

6. [適用後の確認](#適用後の確認) を行う。

`make switch` は以下を行う:

- Determinate Nix Installer が入っていることを確認
- repo が `~/dotfiles` にあることを確認
- 旧 `~/.config` checkout に未コミット変更が残っていないことを確認
- 初回のみ nix-darwin が管理する shell 初期化ファイルを `*.before-nix-darwin` に退避 (`/etc/bashrc`, `/etc/zshrc`)
- `darwin-rebuild switch` で nix-darwin と home-manager をまとめて適用。`darwin-rebuild` が PATH に無ければ、`flake.lock` で固定した nix-darwin を `nix run` する

既に存在するファイルとぶつかった場合、home-manager は元のファイルを `<name>.before-hm` に退避してから置き換える。

### ~/.config から移行する

以前はこの repo を `~/.config` に直接 clone していた。home-manager はリンク元と同じ場所を管理できないため、`~/dotfiles` に移す。

1. `~/.config` の未コミット変更を commit して push する。残っていると `make switch` が止まる。

   ```sh
   git -C ~/.config status
   ```

2. `~/dotfiles` に clone して適用する。

   ```sh
   git clone git@github.com:tyzerrr/dotfiles.git ~/dotfiles
   cd ~/dotfiles/nix
   make switch
   ```

3. 新しいターミナルで動作を確認したら、`~/.config/.git` を退避する (`~/.config` はもう repo ではない)。

   ```sh
   mv ~/.config/.git ~/.config.git.bak
   ```

4. 退避された `*.before-hm` を確認し、不要なら片付ける。

   ```sh
   find ~/.config ~/.claude/ ~ -maxdepth 3 -name '*.before-hm' 2>/dev/null
   ```

### 適用後の確認

nix で入れたコマンドは `~/.nix-profile` から先に解決される。Homebrew や MacPorts のものが後に続いてもよく、見るのは1行目だけ。

```sh
which -a kubectl cmake emacs codex
```

```text
/Users/<you>/.nix-profile/bin/kubectl
/opt/homebrew/bin/kubectl
/Users/<you>/.nix-profile/bin/cmake
/opt/homebrew/bin/cmake
/Users/<you>/.nix-profile/bin/emacs
/Users/<you>/.nix-profile/bin/codex
```

nix で入れた GUI アプリは `~/Applications/Home Manager Apps` に入る。

```sh
ls ~/Applications/"Home Manager Apps"
```

```text
AeroSpace.app  Emacs.app  OmniWM.app  pinentry-mac.app  TemporaryWindow.app  WezTerm.app
```

launchd agent (AeroSpace と OmniWM の枠再描画 watcher) が動いている。1列目は PID、2列目は直近の終了ステータスで `0` になっていればよい。

```sh
launchctl list | grep -E 'aerospace|omniwm'
```

```text
77548   0       org.nix-community.home.aerospace
61977   0       org.nixos.omniwm-border-refresh
```

直接リンクしている設定が `~/dotfiles` を指している。素の `readlink` は途中の `/nix/store/...-home-manager-files/...` で止まるので、`-f` で最後までたどる。

```sh
readlink -f ~/.config/nvim ~/.config/karabiner ~/.claude/settings.json
```

```text
/Users/<you>/dotfiles/nvim
/Users/<you>/dotfiles/karabiner
/Users/<you>/dotfiles/.claude/settings.json
```

`/nix/store/...` で終わる場合、そのファイルは repo へのリンクではなく store のコピーになっている。

AeroSpace / OmniWM / Karabiner-Elements の Accessibility 権限は宣言できない。初回と、nix で入れたアプリが更新されたあとに System Settings → Privacy & Security → Accessibility で許可する。

## 日常の操作

```sh
cd ~/dotfiles/nix
make build                  # 適用せずビルドのみ (./result に成果物)
make switch                 # 適用
make rollback               # 前の世代に戻す
make generations            # 世代一覧
make update                 # flake.lock を更新
make switch UPDATE_LOCK=1   # flake.lock の更新を許可して適用
```

設定を変更するときの流れ:

1. `git pull` で最新の main を取り込む
2. 設定を編集する
3. `make build` でビルドが通ることを確認する
4. `make switch` で適用する (直接リンクしている設定は編集した時点で反映済み)
5. commit して push する

普段の適用では `--no-update-lock-file` を付けている (`make switch` はデフォルトで付与)。`flake.lock` の更新が必要な場合は失敗するので、PC ごとに勝手な lock 差分が生まれない。lock の更新は1台で `make update` してから commit し、他の PC では pull して `make switch` する。

## 設定の追加・変更

- ツールの設定: `nix/home/<tool>.nix` を作って `nix/home.nix` の `imports` に足す
- パッケージ: `nix/home.nix` の `home.packages`
- Homebrew にしか無いもの: 全マシン共通なら `nix/darwin.nix`、マシン固有なら `nix/hosts/<user>.nix`
- helm の repository: `nix/home/helm.nix` (`helm repo add` は read-only なので失敗する)
- macOS の defaults: `nix/hosts/<user>.nix` の `system.defaults`

`nix/home/` などに新しく作ったファイルは、`git add` するまで flake から見えない。

## トラブルシューティング

| 症状 | 対処 |
| --- | --- |
| `error: this repository must be cloned to ~/dotfiles` | repo を `~/dotfiles` に clone し直し、そこで `make switch` する |
| `error: ~/.config still has uncommitted changes in the old dotfiles checkout` | `~/.config` の変更を commit / push し、`~/dotfiles` で pull してから再実行する |
| `make switch` 後に設定ファイルが消えたように見える | `<name>.before-hm` に退避されている |
| ウィンドウマネージャーなどが操作を受け付けない | Accessibility 権限を付け直す |
| 適用後に問題が起きた | `make rollback` で前の世代に戻す |
| 新しく作った `.nix` ファイルが見つからない | `git add` してから再実行する |

## CI

`.github/workflows/ci.yml` で PR ごとに以下を確認する。

- 両 profile の `darwinConfigurations.<profile>.system` を macOS runner でビルド (適用はしない)
- `nix flake check`
- gitleaks で履歴全体のシークレットスキャン (設定は `.gitleaks.toml`)
