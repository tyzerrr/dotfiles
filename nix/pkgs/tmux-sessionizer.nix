{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tmux-sessionizer";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "tyzerrr";
    repo = "tmux-sessionizer";
    rev = "v${version}";
    sha256 = "0zws54s4ykjpn0095vyg6apzbypyflcmd7agnif4vxwnihvk6z6x";
  };

  vendorHash = "sha256-Zc9B5qnDoBQfYXYadLFAuR55MXy6NQp7nOJ3854NYLs=";

  # 公式リリース(goreleaser)と同じ形式でバージョンを埋め込む
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # upstream のテストが Nix sandbox の $HOME ('') で ~ 展開に失敗するためスキップ
  doCheck = false;

  postInstall = ''
    mv $out/bin/my-tmux-sessionizer $out/bin/tmux-sessionizer
  '';

  meta.mainProgram = "tmux-sessionizer";
}
