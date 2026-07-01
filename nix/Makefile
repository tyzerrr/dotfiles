# nix-darwin + home-manager を一発適用する Makefile
#
# 使い方:
#   make switch              # 現在のユーザー名を profile として適用
#   make switch PROFILE=araki
#   make build               # 適用せずビルドのみ
#   make update              # flake の全 input を最新へ更新 (flake.lock 更新)
#   make rollback            # 前の世代に戻す
#   make generations         # 世代一覧
#
# profile は flake の darwinConfigurations 名 (= OS ユーザー名)。
# darwin-rebuild switch 1 回で nix-darwin (Homebrew cask 等) と home-manager の両方が適用される。

CONFIG_DIR := $(HOME)/.config
NIX_DIR := $(CONFIG_DIR)/nix
FLAKE := $(NIX_DIR)
PROFILE ?= $(USER)
# Makefile では # がコメント開始になるため \# でエスケープ
FLAKE_REF := $(FLAKE)\#$(PROFILE)
# Determinate Nix は nix-command / flakes を既定で有効化しているため
# --extra-experimental-features は不要。

DARWIN_REBUILD := $(shell command -v darwin-rebuild 2>/dev/null)
ifeq ($(DARWIN_REBUILD),)
  REBUILD := nix run nix-darwin/master\#darwin-rebuild --
else
  REBUILD := $(DARWIN_REBUILD)
endif

LOCK_FLAGS := --no-update-lock-file
ifeq ($(UPDATE_LOCK),1)
  LOCK_FLAGS :=
endif

.PHONY: help switch build update rollback generations prepare prepare-system check-determinate

help:
	@echo "Usage:"
	@echo "  make switch [PROFILE=$(PROFILE)]   Apply nix-darwin + home-manager"
	@echo "  make build  [PROFILE=$(PROFILE)]   Build only (no activation)"
	@echo "  make update                        Update all flake inputs (flake.lock)"
	@echo "  make rollback                      Roll back to previous generation"
	@echo "  make generations                   List system generations"
	@echo ""
	@echo "Options:"
	@echo "  PROFILE=<name>    darwinConfigurations name (default: \$$USER)"
	@echo "  UPDATE_LOCK=1     Allow flake.lock updates during switch/build"

check-determinate:
	@if [ ! -f /nix/receipt.json ] && [ ! -f /etc/nix/nix.custom.conf ]; then \
		echo "error: Determinate Nix Installer markers were not found."; \
		echo "Install Determinate Nix first: https://install.determinate.systems/nix"; \
		exit 1; \
	fi

# 初回のみ: nix-darwin が管理する shell 初期化ファイルを退避 (冪等)
# /etc/nix は Determinate Nix Installer に管理させるため触らない。
# バックアップ (*.before-nix-darwin) が既にあればスキップ
prepare prepare-system:
	@for f in /etc/bashrc /etc/zshrc; do \
		backup="$$f.before-nix-darwin"; \
		if [ -f "$$backup" ]; then \
			echo "prepare-system: already migrated ($$backup exists)"; \
		elif [ -f "$$f" ]; then \
			echo "prepare-system: moving $$f -> $$backup"; \
			sudo mv "$$f" "$$backup"; \
		fi; \
	done

switch: check-determinate prepare-system
	@echo "switch: profile=$(PROFILE) flake=$(FLAKE_REF)"
ifeq ($(DARWIN_REBUILD),)
	sudo env HOME="$(HOME)" USER="$(USER)" $(REBUILD) switch --flake "$(FLAKE_REF)" $(LOCK_FLAGS)
else
	sudo $(REBUILD) switch --flake "$(FLAKE_REF)" $(LOCK_FLAGS)
endif

build:
	@echo "build: profile=$(PROFILE) flake=$(FLAKE_REF)"
	$(REBUILD) build --flake "$(FLAKE_REF)" $(LOCK_FLAGS)

# flake.nix の全 input (nixpkgs / nix-darwin / home-manager / nix-claude-code 等)
# をまとめて最新へ更新し flake.lock を書き換える。
# 反映するには続けて `make switch` を実行する。
update:
	@echo "update: updating all flake inputs in $(NIX_DIR)"
	nix flake update --flake "$(FLAKE)"

rollback:
	sudo $(REBUILD) --rollback

generations:
	$(REBUILD) --list-generations
