# ALICE overlay for nixpkgs
final: prev: {
  alice = {
    # Layer 1: ROOT with ALICE overrides
    root = final.callPackage ./hep/root.nix {
      inherit (prev) root arrow-cpp protobuf mold;
      pythia = prev.pythia or null;
    };

    # Layer 2a: Simple packages
    faircmakemodules = final.callPackage ./hep/faircmakemodules.nix {};
    vc = final.callPackage ./hep/vc.nix {};
    vmc = final.callPackage ./hep/vmc.nix { root = final.alice.root; };
    fairlogger = final.callPackage ./hep/fairlogger.nix {};
    libinfologger = final.callPackage ./alice/libinfologger.nix {};
    common-o2 = final.callPackage ./alice/common-o2.nix {};
    mlmodels = final.callPackage ./alice/mlmodels.nix {};

    # Layer 2b: Medium packages
    fairmq = final.callPackage ./hep/fairmq.nix {
      inherit (final.alice) faircmakemodules fairlogger;
    };
    geant4 = final.callPackage ./hep/geant4.nix {};
    geant3 = final.callPackage ./hep/geant3.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
    };
    vgm = final.callPackage ./hep/vgm.nix {
      root = final.alice.root;
      geant4 = final.alice.geant4;
    };
    configuration = final.callPackage ./alice/configuration.nix {
      inherit (final.alice) ppconsul;
    };
    monitoring = final.callPackage ./alice/monitoring.nix {
      inherit (final.alice) libinfologger;
    };
    libjalien-o2 = final.callPackage ./alice/libjalienO2.nix {};
    bookkeeping-api = final.callPackage ./alice/bookkeeping-api.nix {};
    ppconsul = final.callPackage ./alice/ppconsul.nix {};
    alice-grid-utils = final.callPackage ./alice/alice-grid-utils.nix {};

    # Layer 2c: Integration packages
    geant4_vmc = final.callPackage ./hep/geant4_vmc.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
      geant4 = final.alice.geant4;
      vgm = final.alice.vgm;
    };
    mcsteplogger = final.callPackage ./hep/mcsteplogger.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
    };
    kfparticle = final.callPackage ./hep/kfparticle.nix {
      root = final.alice.root;
      vc = final.alice.vc;
    };
    fairroot = final.callPackage ./hep/fairroot.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
      fairlogger = final.alice.fairlogger;
      faircmakemodules = final.alice.faircmakemodules;
      geant3 = final.alice.geant3;
      geant4 = final.alice.geant4;
    };
    debuggui = final.callPackage ./alice/debuggui.nix {};
    jalien-root = final.callPackage ./alice/jalien-root.nix {
      root = final.alice.root;
      alice-grid-utils = final.alice.alice-grid-utils;
    };
    # Use nixpkgs onnxruntime (v1.23.2) — close enough to ALICE's v1.22.0
    # Tests fail with GCC 15 (-fno-rtti + typeid), library itself builds fine
    onnxruntime = (prev.onnxruntime.override { pythonSupport = false; }).overrideAttrs (old: {
      doCheck = false;
    });

    # Layer 3: ALICE applications
    o2 = final.callPackage ./alice/o2.nix {
      root = final.alice.root;
      fairroot = final.alice.fairroot;
      fairmq = final.alice.fairmq;
      fairlogger = final.alice.fairlogger;
      vmc = final.alice.vmc;
      vc = final.alice.vc;
      geant3 = final.alice.geant3;
      geant4 = final.alice.geant4;
      geant4_vmc = final.alice.geant4_vmc;
      mcsteplogger = final.alice.mcsteplogger;
      configuration = final.alice.configuration;
      monitoring = final.alice.monitoring;
      common-o2 = final.alice.common-o2;
      libinfologger = final.alice.libinfologger;
      debuggui = final.alice.debuggui;
      jalien-root = final.alice.jalien-root;
      libjalien-o2 = final.alice.libjalien-o2;
      bookkeeping-api = final.alice.bookkeeping-api;
      mlmodels = final.alice.mlmodels;
      onnxruntime = final.alice.onnxruntime;
      kfparticle = final.alice.kfparticle;
    };
    o2physics = final.callPackage ./alice/o2physics.nix {
      o2 = final.alice.o2;
      onnxruntime = final.alice.onnxruntime;
      kfparticle = final.alice.kfparticle;
      libjalien-o2 = final.alice.libjalien-o2;
    };
  };
}
