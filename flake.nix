{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-23.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

    nixosConfigurations.qinghe = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs =  { hdd = "ata-INTEL_SSDSCKKF256G8H_BTLA81651HQR256J"; };
      modules = [
        ./configuration.nix

        ./hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
        }

        ({ pkgs, ... }: {
          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

        })
      ];
    };

  };
}
