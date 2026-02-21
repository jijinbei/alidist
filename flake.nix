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
        a = pkgs.alice;
      in
      {
        packages = {
          default = a.root;

          # Layer 1
          root = a.root;

          # Layer 2a
          faircmakemodules = a.faircmakemodules;
          vc = a.vc;
          vmc = a.vmc;
          fairlogger = a.fairlogger;
          libinfologger = a.libinfologger;
          common-o2 = a.common-o2;
          mlmodels = a.mlmodels;

          # Layer 2b
          fairmq = a.fairmq;
          geant4 = a.geant4;
          geant3 = a.geant3;
          vgm = a.vgm;
          configuration = a.configuration;
          monitoring = a.monitoring;
          libjalien-o2 = a.libjalien-o2;
          bookkeeping-api = a.bookkeeping-api;
          ppconsul = a.ppconsul;

          # Layer 2c
          geant4_vmc = a.geant4_vmc;
          mcsteplogger = a.mcsteplogger;
          kfparticle = a.kfparticle;
          fairroot = a.fairroot;
          debuggui = a.debuggui;
          jalien-root = a.jalien-root;
          onnxruntime = a.onnxruntime;

          # Layer 3
          o2 = a.o2;
          o2physics = a.o2physics;
        };

        devShells.default = pkgs.mkShell {
          name = "alice-dev";
          packages = [
            a.root
            pkgs.cmake
            pkgs.ninja
          ];
          shellHook = ''
            echo "ALICE dev shell (Phase 2)"
            echo "  ROOT: ${a.root.version}"
          '';
        };

        devShells.o2 = pkgs.mkShell {
          name = "alice-o2-dev";
          packages = [
            a.o2
            pkgs.cmake
            pkgs.ninja
          ];
          shellHook = ''
            echo "ALICE O2 dev shell"
          '';
        };

        devShells.o2physics = pkgs.mkShell {
          name = "alice-o2physics-dev";
          packages = [
            a.o2physics
            pkgs.cmake
            pkgs.ninja
          ];
          shellHook = ''
            echo "ALICE O2Physics dev shell"
          '';
        };
      }
    );
}
