# nix-darwin + home-manager を一発適用する Makefile
#
# 使い方:
#   make switch              # 現在のユーザー名を profile として適用
#   make switch PROFILE=araki
#   make build               # 適用せずビルドのみ
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
# sudo nix run (初回 bootstrap) は root の nix 設定を使う。
# /etc/nix/nix.conf 退避後は experimental-features が無いので明示的に渡す。
NIX_EXPERIMENTAL := --extra-experimental-features 'nix-command flakes'

DARWIN_REBUILD := $(shell command -v darwin-rebuild 2>/dev/null)
ifeq ($(DARWIN_REBUILD),)
  REBUILD := nix $(NIX_EXPERIMENTAL) run nix-darwin/master\#darwin-rebuild --
else
  REBUILD := $(DARWIN_REBUILD)
endif

LOCK_FLAGS := --no-update-lock-file
ifeq ($(UPDATE_LOCK),1)
  LOCK_FLAGS :=
endif

.PHONY: help switch build rollback generations prepare prepare-system

help:
	@echo "Usage:"
	@echo "  make switch [PROFILE=$(PROFILE)]   Apply nix-darwin + home-manager"
	@echo "  make build  [PROFILE=$(PROFILE)]   Build only (no activation)"
	@echo "  make rollback                      Roll back to previous generation"
	@echo "  make generations                   List system generations"
	@echo ""
	@echo "Options:"
	@echo "  PROFILE=<name>    darwinConfigurations name (default: \$$USER)"
	@echo "  UPDATE_LOCK=1     Allow flake.lock updates during switch/build"

# 初回のみ: nix-darwin が管理する /etc ファイルを退避 (冪等)
# バックアップ (*.before-nix-darwin) が既にあればスキップ
prepare prepare-system:
	@for f in /etc/nix/nix.conf /etc/bashrc /etc/zshrc; do \
		backup="$$f.before-nix-darwin"; \
		if [ -f "$$backup" ]; then \
			echo "prepare-system: already migrated ($$backup exists)"; \
		elif [ -f "$$f" ]; then \
			echo "prepare-system: moving $$f -> $$backup"; \
			sudo mv "$$f" "$$backup"; \
		fi; \
	done

switch: prepare-system
	@echo "switch: profile=$(PROFILE) flake=$(FLAKE_REF)"
ifeq ($(DARWIN_REBUILD),)
	sudo env HOME="$(HOME)" USER="$(USER)" $(REBUILD) switch --flake "$(FLAKE_REF)" $(LOCK_FLAGS)
else
	sudo $(REBUILD) switch --flake "$(FLAKE_REF)" $(LOCK_FLAGS)
endif

build:
	@echo "build: profile=$(PROFILE) flake=$(FLAKE_REF)"
	$(REBUILD) build --flake "$(FLAKE_REF)" $(LOCK_FLAGS)

rollback:
	sudo $(REBUILD) --rollback

generations:
	$(REBUILD) --list-generations
