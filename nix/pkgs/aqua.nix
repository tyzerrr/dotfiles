{ buildGoModule, fetchFromGitHub }:

# aquaproj/aqua (宣言的 CLI バージョンマネージャ) は nixpkgs 未収録のため自作
buildGoModule rec {
  pname = "aqua";
  version = "2.60.1";

  src = fetchFromGitHub {
    owner = "aquaproj";
    repo = "aqua";
    rev = "v${version}";
    hash = "sha256-FARSdESiu6OP/VrwPhyGkqpJP2ZDOn6kg9fVJDQnq3Q=";
  };

  vendorHash = "sha256-us+mpUTRdL3DdKDSRtZ0sXtIzzsz3blVKKI5ElIrNT0=";
  subPackages = [ "cmd/aqua" ];

  ldflags = [ "-s" "-w" "-X main.version=v${version}" ];

  meta.mainProgram = "aqua";
}
