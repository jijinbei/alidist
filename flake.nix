{
  description = "ALICE experiment software stack — Nix layer for alidist";

  nixConfig = {
    extra-substituters = [ "https://alice-nix.cachix.org" ];
    extra-trusted-public-keys = [ "alice-nix.cachix.org-1:AcbGlujqdttNTQ5Hu3DXB6DVPmSD42whLdskx9OO108=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # O2 / O2Physics sources — pinned via flake.lock
    # Update with: nix flake lock --update-input o2-src
    #              nix flake lock --update-input o2physics-src
    o2-src = {
      url = "github:AliceO2Group/AliceO2/dev";
      flake = false;
    };
    o2physics-src = {
      url = "github:AliceO2Group/O2Physics/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, o2-src, o2physics-src }:
    let
      overlay = import ./nix/overlay.nix { inherit o2-src o2physics-src; };
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
          root = a.root;
          faircmakemodules = a.faircmakemodules;
          vc = a.vc;
          vmc = a.vmc;
          fairlogger = a.fairlogger;
          libinfologger = a.libinfologger;
          common-o2 = a.common-o2;
          mlmodels = a.mlmodels;
          fairmq = a.fairmq;
          geant4 = a.geant4;
          geant3 = a.geant3;
          vgm = a.vgm;
          configuration = a.configuration;
          monitoring = a.monitoring;
          libjalien-o2 = a.libjalien-o2;
          bookkeeping-api = a.bookkeeping-api;
          ppconsul = a.ppconsul;
          geant4_vmc = a.geant4_vmc;
          mcsteplogger = a.mcsteplogger;
          kfparticle = a.kfparticle;
          fairroot = a.fairroot;
          debuggui = a.debuggui;
          jalien-root = a.jalien-root;
          onnxruntime = a.onnxruntime;
          o2 = a.o2;
          o2physics = a.o2physics;
        };

        devShells.default = pkgs.mkShell {
          name = "alice-dev";
          packages = [
            a.root
            pkgs.cmake
            pkgs.ninja
            pkgs.python3
            pkgs.git
          ];
          shellHook = ''
            echo "ALICE dev shell"
            echo "  ROOT:  ${a.root.version}"
            echo "  cmake: $(cmake --version | head -1)"
          '';
        };

        devShells.o2 = pkgs.mkShell {
          name = "alice-o2-dev";
          inputsFrom = [ a.o2 ];
          packages = [
            a.o2
            pkgs.cmake
            pkgs.ninja
            pkgs.python3
            pkgs.gdb
            pkgs.git
          ];
          shellHook = ''
            export O2_ROOT="${a.o2}"
            export VMCWORKDIR="${a.o2}/share"
            export LD_LIBRARY_PATH="${a.o2}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export ROOT_INCLUDE_PATH="${pkgs.lib.concatStringsSep ":" [
              "${a.o2}/include"
              "${a.o2}/include/GPU"
              "${a.fairroot}/include"
              "${a.fairmq}/include/fairmq"
              "${a.fairlogger}/include"
              "${a.vmc}/include/vmc"
              "${pkgs.boost.dev}/include"
              "${pkgs.openssl.dev}/include"
            ]}''${ROOT_INCLUDE_PATH:+:$ROOT_INCLUDE_PATH}"
            echo "ALICE O2 dev shell"
            echo "  O2:   ${a.o2.version}"
            echo "  ROOT: ${a.root.version}"
          '';
        };

        devShells.o2physics = pkgs.mkShell {
          name = "alice-o2physics-dev";
          inputsFrom = [ a.o2physics ];
          packages = [
            a.o2physics
            a.o2
            pkgs.cmake
            pkgs.ninja
            pkgs.python3
            pkgs.gdb
            pkgs.git
          ];
          shellHook = ''
            # O2/O2Physics root directories — workflows use these to find configs
            export O2_ROOT="${a.o2}"
            export O2PHYSICS_ROOT="${a.o2physics}"
            export VMCWORKDIR="${a.o2}/share"

            # dlopen() plugin loading — O2 loads libraries at runtime via dlopen
            export LD_LIBRARY_PATH="${a.o2}/lib:${a.o2physics}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

            # ROOT/cling runtime header search — needed for dictionaries and JIT
            export ROOT_INCLUDE_PATH="${pkgs.lib.concatStringsSep ":" [
              "${a.o2physics}/include"
              "${a.o2}/include"
              "${a.o2}/include/GPU"
              "${a.fairroot}/include"
              "${a.fairmq}/include/fairmq"
              "${a.fairlogger}/include"
              "${a.vmc}/include/vmc"
              "${pkgs.boost.dev}/include"
              "${pkgs.openssl.dev}/include"
              "${pkgs.fmt.dev}/include"
            ]}''${ROOT_INCLUDE_PATH:+:$ROOT_INCLUDE_PATH}"

            echo "ALICE O2Physics dev shell"
            echo "  O2Physics: ${a.o2physics.version}"
            echo "  O2:        ${a.o2.version}"
            echo "  ROOT:      ${a.root.version}"
          '';
        };
      }
    );
}
