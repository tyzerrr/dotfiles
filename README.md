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

### 2. Nix + home-manager で各種ツールをインストール
`araki` は personal、`t-b-araki` は work 用のprofile。
どちらも同じHome Manager設定を使い、usernameとhomeDirectoryだけprofileごとに切り替える。

初回は適用したいprofileを指定してインストール。

```sh
nix run home-manager/master -- switch --flake ~/.config/nix#araki
nix run home-manager/master -- switch --flake ~/.config/nix#t-b-araki
```

2回目以降は以下のコマンドで適用。(home-managerが有効になる)

```sh
home-manager switch --flake ~/.config/nix#araki --locked
home-manager switch --flake ~/.config/nix#t-b-araki --locked
```

普段の適用では `--locked` を付ける。`flake.lock` の更新が必要な場合は失敗するので、PCごとに勝手なlock差分が生まれない。

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
home-manager build
```

### 2. Rollback
`home-manager switch`して、何か問題が起きたら以前のVersionにRollbackすることが可能。

```sh
home-manager switch --rollback
```

### 3. Generations
`home-manager switch`による設定ファイルの世代を確認したい時は以下。

```sh
home-manager generations
```

### 4. Nix packageを追加する
package追加時は、まず最新のmainを取り込んでから `nix/home.nix` の `home.packages` に追加する。

```sh
cd ~/.config
git pull --rebase
```

追加後、まずは `flake.lock` を更新せずに適用する。

```sh
home-manager switch --flake ~/.config/nix#araki --locked
home-manager switch --flake ~/.config/nix#t-b-araki --locked
```

`--locked` で通る場合、追加したpackageは現在の `flake.lock` で固定されたnixpkgsに存在するので、基本的に `nix/home.nix` だけcommitする。

```sh
git add nix/home.nix
git commit -m "chore(nix): add <package>"
git push
```

`--locked` でlock更新が必要なエラーになる場合だけ、明示的に `flake.lock` を更新する。

```sh
cd ~/.config/nix
nix flake update
home-manager switch --flake .#araki --locked
home-manager switch --flake .#t-b-araki --locked
cd ..
git add nix/home.nix nix/flake.lock
git commit -m "chore(nix): add <package>"
git push
```

他のPCでは `flake.lock` を更新しない。変更を取り込んで、該当profileを `--locked` で適用する。

```sh
cd ~/.config
git pull --rebase
home-manager switch --flake ~/.config/nix#araki --locked
home-manager switch --flake ~/.config/nix#t-b-araki --locked
```
