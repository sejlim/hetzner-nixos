{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    trustolino-landingpage.url = "github:sejlim/trustolino-landingpage";
  };

  outputs =
    {
      nixpkgs,
      vscode-server,
      trustolino-landingpage,
      ...
    }:
    {
      nixosConfigurations = {
        selims-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            vscode-server.nixosModules.default
            trustolino-landingpage.nixosModules.default
          ];
        };
      };
    };
}
