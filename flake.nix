{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-23.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

    nixosConfigurations.qinghe = nixpkgs.lib.nixosSystem (import ./desktop.nix {
      hdd = "nvme-SAMSUNG_MZVLV256HCHP-000H1_S2CSNA0J547878";
      inherit inputs;
    });

    nixosConfigurations.yinzhou = nixpkgs.lib.nixosSystem (import ./desktop.nix {
      hdd = "ata-INTEL_SSDSCKKF256G8H_BTLA81651HQR256J";
      inherit inputs;
    });

  };
}
