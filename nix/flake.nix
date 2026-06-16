{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-claude-code, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nix-claude-code.overlays.default
          self.overlays.default
        ];
      };
      mkHomeConfiguration = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username;
          homeDirectory = "/Users/${username}";
        };
        modules = [ ./home.nix ];
      };
      mkDarwinConfiguration = username: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.pkgs = pkgs;
            home-manager.useGlobalPkgs = true;
            # Keep home-manager packages in ~/.nix-profile instead of
            # nix-darwin's /etc/profiles/per-user/$USER profile.
            home-manager.useUserPackages = false;
            home-manager.extraSpecialArgs = {
              inherit username;
              homeDirectory = "/Users/${username}";
            };
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };
    in {
      # 自作 overlay（自作パッケージ + 既存パッケージ上書き）
      overlays.default = import ./overlays;

      # 自作パッケージ。`nix build .#gwq` で単体ビルド・ハッシュ取得できる
      packages.${system} = import ./pkgs pkgs;

      homeConfigurations.araki = mkHomeConfiguration "araki";
      homeConfigurations.t-b-araki = mkHomeConfiguration "t-b-araki";

      darwinConfigurations.araki = mkDarwinConfiguration "araki";
      darwinConfigurations.t-b-araki = mkDarwinConfiguration "t-b-araki";
    };
}
