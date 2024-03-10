{ hdd, inputs, ... }:
let inherit (inputs) home-manager;
in {
  system = "x86_64-linux";

  specialArgs = { inherit hdd inputs; };

  modules = [
    ./configuration.nix

    ./hardware-configuration.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
    }

  ];
}
