# nixpkgs に適用する自作 overlay
final: prev:
# 自作パッケージを追加
(import ../pkgs final)
# 既存パッケージの上書き
// {
  # kubernetes-helm 4.2.0 は nixpkgs の checkPhase が壊れている
  # (移動済みの test ファイルへの substituteInPlace が失敗) ため check を無効化
  kubernetes-helm = prev.kubernetes-helm.overrideAttrs (_: { doCheck = false; });
}
