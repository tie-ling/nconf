{ hdd, inputs, hostname, ... }:
let inherit (inputs) home-manager;
in {
  system = "x86_64-linux";

  specialArgs = { inherit hdd inputs; };

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
