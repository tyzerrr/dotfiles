# nixpkgs に適用する自作 overlay
final: prev:
# 自作パッケージを追加
(import ../pkgs final)
# 既存パッケージの上書き
// {
  # kubernetes-helm 4.2.0 は nixpkgs の checkPhase が壊れている
  # (移動済みの test ファイルへの substituteInPlace が失敗) ため check を無効化
  kubernetes-helm = prev.kubernetes-helm.overrideAttrs (_: { doCheck = false; });

  # nixpkgs の cargo-setup-hook が *-sys crate に system ライブラリの使用を強制する
  # (AWS_LC_SYS_USE_SYSTEM 等) ようになったが、codex の package.nix が追従しておらず
  # pkg-config で見つからずビルドが失敗するため不足分を補う
  codex = prev.codex.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ (with final; [ aws-lc zstd sqlite rust-jemalloc-sys oniguruma ]);
  });
}
