{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    zakkig.url = "github:sejlim/zakkig";
  };

  outputs = { nixpkgs, vscode-server, zakkig, ... }: {
    nixosConfigurations = {
      selims-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          vscode-server.nixosModules.default
          zakkig.nixosModules.default
        ];
      };
    };
  };
}
