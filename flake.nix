{
  inputs.nixpkgs.url = "nixpkgs/master";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }@inputs: {

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

    nixosConfigurations.qinghe = nixpkgs.lib.nixosSystem (import ./desktop.nix {
      hdd = "nvme-SAMSUNG_MZVLV256HCHP-000H1_S2CSNA0J547878";
      hostname = "qinghe";
      inherit inputs;
    });

    nixosConfigurations.yinzhou = nixpkgs.lib.nixosSystem
      (import ./desktop.nix {
        hdd = "ata-INTEL_SSDSCKKF256G8H_BTLA81651HQR256J";
        hostname = "yinzhou";
        inherit inputs;
      });

    nixosConfigurations.tieling = nixpkgs.lib.nixosSystem (import ./server.nix {
      hostname = "tieling";
      inherit inputs;
    });

  };
}
