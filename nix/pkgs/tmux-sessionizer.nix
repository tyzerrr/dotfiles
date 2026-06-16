{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tmux-sessionizer";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "tyzerrr";
    repo = "tmux-sessionizer";
    rev = "v${version}";
    sha256 = "0pkskqbsnma8c262kys7r5ll9ivrwjp4iw08iwykqrrizqzzdlcd";
  };

  vendorHash = "sha256-bMOY0HQqvLg7vnGcUUA+sfK2lzbEin4Cp7kY93i9Jhw=";

  postInstall = ''
    mv $out/bin/my-tmux-sessionizer $out/bin/tmux-sessionizer
  '';

  meta.mainProgram = "tmux-sessionizer";
}
