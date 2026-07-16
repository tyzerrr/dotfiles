# 自作パッケージの集約。callPackage を持つ pkgs を受け取り、
# パッケージ名 → derivation の attrset を返す。新規追加はここに1行足すだけ。
pkgs: {
  aqua = pkgs.callPackage ./aqua.nix { };
  gwq = pkgs.callPackage ./gwq.nix { };
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer.nix { };
}
