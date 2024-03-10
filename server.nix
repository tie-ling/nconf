{ inputs, hostname, ... }:
let inherit (inputs) home-manager;
in {
  system = "x86_64-linux";

  specialArgs = { inherit inputs; };

  modules = [
    ./server-configuration.nix

    ({ networking.hostName = hostname; })

    ./server-hardware-configuration.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
    }

  ];
}
