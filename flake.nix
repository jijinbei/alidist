{
  description = "ALICE experiment software stack — Nix layer for alidist";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = import ./nix/overlay.nix;
    in
    {
      overlays.default = overlay;
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          root = pkgs.alice.root;
          default = pkgs.alice.root;
        };

        devShells.default = pkgs.mkShell {
          name = "alice-dev";
          packages = [
            pkgs.alice.root
            pkgs.cmake
            pkgs.ninja
          ];
          shellHook = ''
            echo "ALICE dev shell (Layer 0-1)"
            echo "  ROOT: ${pkgs.alice.root.version}"
          '';
        };
      }
    );
}
