{ pkgs, ... }:
let
  repositories = {
    prometheus-community = "https://prometheus-community.github.io/helm-charts";
  };
in
{
  # helm repo add は認証情報も repositories.yaml に書き込むため、公開 repo に
  # 混入しないよう Nix で宣言し read-only にする。repo の追加はここで行う
  xdg.configFile."helm/repositories.yaml".source = (pkgs.formats.yaml { }).generate "helm-repositories" {
    apiVersion = "";
    generated = "0001-01-01T00:00:00Z";
    repositories = pkgs.lib.mapAttrsToList (name: url: {
      inherit name url;
      caFile = "";
      certFile = "";
      keyFile = "";
      insecure_skip_tls_verify = false;
      pass_credentials_all = false;
      username = "";
      password = "";
    }) repositories;
  };
}
