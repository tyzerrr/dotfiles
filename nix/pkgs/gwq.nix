{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "gwq";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;
  subPackages = [ "cmd/gwq" ];

  meta.mainProgram = "gwq";
}
