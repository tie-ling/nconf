{
  # https://status.nixos.org/
  inputs.nixpkgs.url = "nixpkgs/805a384895c696f802a9bf5bf4720f37385df547";
  inputs.home-manager = {
    # https://github.com/nix-community/home-manager/tree/release-24.05
    url = "github:nix-community/home-manager/a1fddf0967c33754271761d91a3d921772b30d0e";
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
        hdd = "nvme-SAMSUNG_MZVL2512HCJQ-00BL2_S64JNF0TA65903";
        hostname = "yinzhou";
        inherit inputs;
      });

    nixosConfigurations.tieling = nixpkgs.lib.nixosSystem (import ./server.nix {
      hostname = "tieling";
      inherit inputs;
    });

  };
}
