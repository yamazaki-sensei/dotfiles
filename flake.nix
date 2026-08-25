{
  description = "hiraku dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: let
    username = "hiraku.578";
    hostname = "ST-M-D3JHGXX37T";
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Existing unmanaged files (e.g. karabiner.json) are moved aside
          # instead of aborting the activation.
          home-manager.backupFileExtension = "backup";
          home-manager.users.${username} = import ./home.nix;
        }
        {
          users.users.${username}.home = "/Users/${username}";
          # Used by homebrew / user-level activation scripts
          system.primaryUser = username;
        }
      ];
    };
  };
}
