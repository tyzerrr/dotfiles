# dotfiles

`~/dotfiles` に clone し、nix-darwin + home-manager で `~/.config` などへ配置する dotfiles。

Neovim (Lua) のように Nix 化しないものも、配置は home-manager が行う。

## 構成

```text
nix/
  flake.nix          nix-darwin + home-manager の flake (profile = OS ユーザー名)
  darwin.nix         全マシン共通の nix-darwin 設定 (Homebrew, launchd agent)
  hosts/<user>.nix   マシン固有の nix-darwin 設定 (追加の Homebrew, system.defaults)
  home.nix           home-manager のエントリポイントとパッケージ一覧
  home/              ツールごとの home-manager モジュール
  pkgs/ overlays/    自作パッケージ
nvim/ kitty/ wezterm/ sketchybar/ ...   Nix 化しない設定の実体
```

各設定の扱いは次の3通り。

| 扱い | 対象 | 編集後の反映 |
| --- | --- | --- |
| Nix で生成 | zsh, oh-my-posh, git, tmux, ghostty, aerospace, gwq, cmux, borders, helm, homebrew の trust リスト, macOS defaults | `make switch` |
| store にコピーして配置 | sketchybar, wezterm, Claude Code の agents/commands/skills, tmux / omniwm の補助スクリプト | `make switch` |
| repo を直接リンク (`mkOutOfStoreSymlink`) | nvim, karabiner, kitty, omniwm の settings.toml, Claude Code の settings.json / mcp.json / CLAUDE.md | 即時 (アプリ自身も書き換えるため) |

直接リンクしているものは `~/dotfiles` 内のファイルそのものなので、アプリが書き換えた差分は `git diff` に出る。

## Prerequisites

### Nix のインストール

Determinate Nix Installer で Nix を入れる。

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

この repository の nix-darwin 設定では `nix.enable = false` にしている。
Nix daemon や `/etc/nix/nix.conf` は Determinate Nix Installer に管理させ、nix-darwin では管理しない。

### Homebrew のインストール

nixpkgs に無いもの (`ghostty`, `mactex`, `sf-symbols`, `socket_vmnet` など) は `nix/darwin.nix` と `nix/hosts/<user>.nix` で宣言した Homebrew で入れるので、事前に入れておく: <https://brew.sh>

## Setup

```sh
git clone git@github.com:tyzerrr/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix
make switch
```

clone 先は `~/dotfiles` 固定 (`nix/flake.nix` の `dotfilesDirOf`)。他の場所からの `make switch` はエラーになる。

`araki` は personal、`t-b-araki` は work 用の profile。profile はデフォルトで現在の OS ユーザー名 (`$USER`)。

```sh
make switch PROFILE=araki
make switch PROFILE=t-b-araki
```

`make switch` は以下を行う:
- Determinate Nix Installer が入っていることを確認
- repo が `~/dotfiles` にあることを確認
- 初回のみ nix-darwin が管理する shell 初期化ファイルを `*.before-nix-darwin` に退避 (`/etc/bashrc`, `/etc/zshrc`)
- `darwin-rebuild switch` で nix-darwin と home-manager をまとめて適用 (`darwin-rebuild` が PATH に無ければ `flake.lock` で固定した nix-darwin を `nix run` する)

既に存在するファイルとぶつかった場合、home-manager は元のファイルを `<name>.before-hm` に退避してから置き換える。

### GUI アプリの権限

AeroSpace / OmniWM / Karabiner-Elements の Accessibility 権限は宣言できないので、初回や nix で入れたアプリの更新後に System Settings → Privacy & Security → Accessibility で許可する。

## ~/.config からの移行

以前はこの repo を `~/.config` に直接 clone していた。home-manager はリンク元と同じ場所を管理できないため、`~/dotfiles` に移す。

1. `~/.config` の未コミット変更を commit して push する (残っていると `make switch` が止まる)
2. `~/dotfiles` に clone して適用する

   ```sh
   git clone git@github.com:tyzerrr/dotfiles.git ~/dotfiles
   cd ~/dotfiles/nix
   make switch
   ```

3. 動作を確認したら、`~/.config/.git` を退避する (`~/.config` はもう repo ではない)

   ```sh
   mv ~/.config/.git ~/.config.git.bak
   ```

4. 不要になった `*.before-hm` を確認して片付ける

   ```sh
   find ~/.config ~/.claude/ -maxdepth 3 -name '*.before-hm'
   ```

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

普段の適用では `--no-update-lock-file` を付けている (`make switch` はデフォルトで付与)。`flake.lock` の更新が必要な場合は失敗するので、PC ごとに勝手な lock 差分が生まれない。lock の更新は1台で `make update` してから commit し、他の PC では pull して `make switch` する。

## 設定の追加・変更

- ツールの設定: `nix/home/<tool>.nix` を作って `nix/home.nix` の `imports` に足す
- パッケージ: `nix/home.nix` の `home.packages`
- Homebrew にしか無いもの: 全マシン共通なら `nix/darwin.nix`、マシン固有なら `nix/hosts/<user>.nix`
- helm の repository: `nix/home/helm.nix` (`helm repo add` は read-only なので失敗する)

## CI

`.github/workflows/ci.yml` で PR ごとに以下を確認する。

- 両 profile の `darwinConfigurations.<profile>.system` を macOS runner でビルド (適用はしない)
- `nix flake check`
- gitleaks で履歴全体のシークレットスキャン (設定は `.gitleaks.toml`)
