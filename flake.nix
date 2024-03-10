{
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs }: {

    nixosConfigurations.qinghe = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./configuration.nix

          ({ pkgs, ... }: {
            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          })
        ];
    };

  };
}
