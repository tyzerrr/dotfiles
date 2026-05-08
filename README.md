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

```sh
nix run home-manager/master -- switch --flake ~/.config/nix#${your-username}
```

> `nix/home.nix` と `nix/flake.nix` の `username` / `homeDirectory` を自分の環境に合わせて書き換えてから実行してくれ。

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
