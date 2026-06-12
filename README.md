# dotfiles

`~/.config` で管理しているdotfiles。

## Prerequisites

### Nix のインストール

```sh
sh <(curl -L https://nixos.org/nix/install)
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

## Setup

### 1. Repository を clone

```sh
git clone --recurse-submodules git@github.com:tyzerrr/dotfiles.git ~/.config
```

`--recurse-submodules` 付きなら次の Step 4 のsubmodule復元は不要。

### 2. Nix (nix-darwin + home-manager) で各種ツールをインストール
`araki` は personal、`t-b-araki` は work 用のprofile。
どちらも同じ home-manager 設定を使い、usernameとhomeDirectoryだけprofileごとに切り替える。
home-manager は nix-darwin に統合してあるので、`darwin-rebuild switch` 一発でシステム設定 (Homebrew cask 等) と home-manager の両方が適用される。**別途 `home-manager switch` は不要。**

> macOS の GUI アプリ等 (例: `ghostty`) は nixpkgs が darwin 非対応なため、`nix/darwin.nix` の Homebrew cask で管理している。Homebrew 本体は事前に入れておくこと: <https://brew.sh>

初回・2回目以降とも、リポジトリ直下で `make switch` を実行する。profile はデフォルトで現在の OS ユーザー名 (`$USER`) が使われる。

```sh
cd ~/.config
make switch
```

別ユーザー用 profile を指定する場合:

```sh
make switch PROFILE=araki
make switch PROFILE=t-b-araki
```

`make switch` は以下を冪等に行う:
- 初回のみ nix-darwin が管理する `/etc` ファイルを `*.before-nix-darwin` に退避 (`/etc/nix/nix.conf`, `/etc/bashrc`, `/etc/zshrc`)
- `darwin-rebuild` が PATH に無ければ `nix run` 経由で実行 (初回)
- あれば `darwin-rebuild switch` で適用 (2回目以降)

その他の Make ターゲット:

```sh
make build                  # 適用せずビルドのみ
make rollback               # 前の世代に戻す
make generations            # 世代一覧
make switch UPDATE_LOCK=1   # flake.lock の更新を許可して適用
```

<details>
<summary>make を使わない場合の手動コマンド</summary>

初回:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix#t-b-araki
```

2回目以降:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#t-b-araki --no-update-lock-file
```

</details>

普段の適用では `--no-update-lock-file` を付ける (`make switch` はデフォルトで付与)。`flake.lock` の更新が必要な場合は失敗するので、PCごとに勝手なlock差分が生まれない。

### 3. Starship をインストール

```sh
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
```

### 4. submodule (`fzf-git.sh`, `ohmyzsh`) を復元

```sh
git -C ~/.config submodule update --init --recursive
```

### 5. ohmyzsh のカスタムプラグインを clone

`zsh-autosuggestions` と `zsh-syntax-highlighting` は ohmyzsh 同梱ではないので別途取得する：

```sh
ZSH_CUSTOM=~/.config/zsh/ohmyzsh/custom
git clone https://github.com/zsh-users/zsh-autosuggestions     $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

### 6. zsh 設定を読み込む

```sh
source ~/.config/zsh/.zshrc
```

## FAQ
### 1. Build, just check
いきなり適用するのが怖い時は、buildだけして成果物を確認することができる。
buildを実行したディレクトリに`result`というLinkが作られるので、そこで成果物を見る。

```sh
cd ~/.config
make build
```

### 2. Rollback
`make switch` して、何か問題が起きたら以前のVersionにRollbackすることが可能。

```sh
make rollback
```

### 3. Generations
`make switch` による設定ファイルの世代を確認したい時は以下。

```sh
make generations
```

### 4. Nix設定を更新する
Nix設定を変更する時は、まず最新のmainを取り込んでから `nix/home.nix` や `nix/flake.nix` を編集する。

```sh
cd ~/.config
git fetch
git rebase origin/main
```

変更後、まずは `flake.lock` を更新せずに適用する。

```sh
cd ~/.config
make switch
```

`--no-update-lock-file` で通る場合、変更は現在の `flake.lock` で固定されたnixpkgsで評価できるので、基本的にNixの設定ファイルだけcommitする。

```sh
git diff
git add nix/home.nix nix/flake.nix nix/darwin.nix
git commit -m "chore(nix): update nix config"
git push
```

`home-manager switch` で生成される以下のsymlinkはGit管理しない。

```text
bat/config
direnv/lib/hm-nix-direnv.sh
git/config
tmux/tmux.conf
```

これらは `.gitignore` 済みなので、`git diff` にはNixの設定変更だけが出る。

`--no-update-lock-file` でlock更新が必要なエラーになる場合だけ、明示的に `flake.lock` を更新する。

```sh
cd ~/.config/nix
nix flake update
cd ..
make switch UPDATE_LOCK=1
git add nix/home.nix nix/flake.lock
git commit -m "chore(nix): update flake lock"
git push
```

他のPCでは `flake.lock` を更新しない。変更を取り込んで、該当profileを `--no-update-lock-file` で適用する。

```sh
cd ~/.config
git fetch
git rebase origin/main
make switch
```
