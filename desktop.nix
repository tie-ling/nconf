{ hdd, inputs, hostname, ... }:
let
  inherit (inputs) home-manager nixpkgs-unstable nixpkgs;
  system = "x86_64-linux";
in {

  inherit system;

  specialArgs = {
    inherit hdd inputs;
    pkgs = import nixpkgs { inherit system; };
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
  };

  modules = [
    ./desktop-configuration.nix

    ({ networking.hostName = hostname; })

    ./desktop-hardware-configuration.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
    }

  ];
}
