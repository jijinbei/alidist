# ALICE overlay for nixpkgs
# Arguments from flake.nix: source inputs for O2 and O2Physics
{ o2-src, o2physics-src }:

final: prev:
let
  # Use mold linker for all ALICE packages (matches defaults-o2.sh)
  # mold is Linux-only; on macOS fall back to the default linker
  moldStdenv = if prev.stdenv.hostPlatform.isLinux
    then prev.stdenvAdapters.useMoldLinker prev.stdenv
    else prev.stdenv;
  callPackage = prev.lib.callPackageWith (final // { stdenv = moldStdenv; });

  # Arrow with Gandiva (JIT expression engine) — required by O2 DPL framework.
  # nixpkgs arrow-cpp doesn't enable Gandiva by default; we add LLVM + clang.
  # Gandiva precompiles C++ to LLVM bitcode using clang; we must point clang
  # at the GCC C++ standard library headers since nixpkgs uses GCC stdenv.
  gcc = prev.stdenv.cc.cc;
  arrow-cpp-gandiva = prev.arrow-cpp.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [
      prev.llvmPackages.llvm
      prev.llvmPackages.llvm.dev
    ];
    nativeBuildInputs = old.nativeBuildInputs ++ [
      prev.llvmPackages.clang-unwrapped
      prev.llvmPackages.llvm
    ];
    cmakeFlags = old.cmakeFlags ++ [
      (prev.lib.cmakeBool "ARROW_GANDIVA" true)
      "-DLLVM_DIR=${prev.llvmPackages.llvm.dev}/lib/cmake/llvm"
      # Tell Gandiva's clang where to find GCC C++ and glibc headers for bitcode compilation
      # Use semicolons so CMake treats this as a list, not multiple arguments
      "-DARROW_GANDIVA_PC_CXX_FLAGS=-isystem;${gcc}/include/c++/${gcc.version};-isystem;${gcc}/include/c++/${gcc.version}/x86_64-unknown-linux-gnu;-isystem;${prev.glibc.dev}/include"
    ];
  });
in {
  alice = {
    # ROOT uses explicit mold CMake flags (not moldStdenv) because ROOT's
    # own mold version check is incompatible with useMoldLinker's cc wrapper.
    root = callPackage ./hep/root.nix {
      inherit (prev) root arrow-cpp protobuf mold;
      pythia = prev.pythia or null;
    };

    inherit arrow-cpp-gandiva;
    faircmakemodules = callPackage ./hep/faircmakemodules.nix {};
    vc = callPackage ./hep/vc.nix {};
    vmc = callPackage ./hep/vmc.nix { root = final.alice.root; };
    fairlogger = callPackage ./hep/fairlogger.nix {};
    libinfologger = callPackage ./alice/libinfologger.nix {};
    common-o2 = callPackage ./alice/common-o2.nix {};
    mlmodels = callPackage ./alice/mlmodels.nix {};

    fairmq = callPackage ./hep/fairmq.nix {
      inherit (final.alice) faircmakemodules fairlogger;
    };
    geant4 = callPackage ./hep/geant4.nix {};
    geant3 = callPackage ./hep/geant3.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
    };
    vgm = callPackage ./hep/vgm.nix {
      root = final.alice.root;
      geant4 = final.alice.geant4;
    };
    configuration = callPackage ./alice/configuration.nix {
      inherit (final.alice) ppconsul;
    };
    monitoring = callPackage ./alice/monitoring.nix {
      inherit (final.alice) libinfologger;
    };
    libjalien-o2 = callPackage ./alice/libjalienO2.nix {};
    bookkeeping-api = callPackage ./alice/bookkeeping-api.nix {};
    ppconsul = callPackage ./alice/ppconsul.nix {};
    alice-grid-utils = callPackage ./alice/alice-grid-utils.nix {};

    geant4_vmc = callPackage ./hep/geant4_vmc.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
      geant4 = final.alice.geant4;
      vgm = final.alice.vgm;
    };
    mcsteplogger = callPackage ./hep/mcsteplogger.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
    };
    kfparticle = callPackage ./hep/kfparticle.nix {
      root = final.alice.root;
      vc = final.alice.vc;
    };
    fairroot = callPackage ./hep/fairroot.nix {
      root = final.alice.root;
      vmc = final.alice.vmc;
      fairlogger = final.alice.fairlogger;
      faircmakemodules = final.alice.faircmakemodules;
      geant3 = final.alice.geant3;
      geant4 = final.alice.geant4;
    };
    debuggui = callPackage ./alice/debuggui.nix {};
    jalien-root = callPackage ./alice/jalien-root.nix {
      root = final.alice.root;
      alice-grid-utils = final.alice.alice-grid-utils;
    };
    # Tests fail with GCC 15 (-fno-rtti + typeid), library itself builds fine
    onnxruntime = (prev.onnxruntime.override {
      pythonSupport = false;
      stdenv = moldStdenv;
    }).overrideAttrs (old: {
      doCheck = false;
    });

    o2 = callPackage ./alice/o2.nix {
      src = o2-src;
      arrow-cpp = arrow-cpp-gandiva;
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
      inherit (prev) xrootd glfw gbenchmark;
    };
    o2physics = callPackage ./alice/o2physics.nix {
      src = o2physics-src;
      o2 = final.alice.o2;
      arrow-cpp = arrow-cpp-gandiva;
      root = final.alice.root;
      vmc = final.alice.vmc;
      vc = final.alice.vc;
      fairlogger = final.alice.fairlogger;
      common-o2 = final.alice.common-o2;
      libinfologger = final.alice.libinfologger;
      fairmq = final.alice.fairmq;
      geant4 = final.alice.geant4;
      geant3 = final.alice.geant3;
      configuration = final.alice.configuration;
      monitoring = final.alice.monitoring;
      bookkeeping-api = final.alice.bookkeeping-api;
      libjalien-o2 = final.alice.libjalien-o2;
      geant4_vmc = final.alice.geant4_vmc;
      mcsteplogger = final.alice.mcsteplogger;
      kfparticle = final.alice.kfparticle;
      fairroot = final.alice.fairroot;
      debuggui = final.alice.debuggui;
      jalien-root = final.alice.jalien-root;
      vgm = final.alice.vgm;
      onnxruntime = final.alice.onnxruntime;
      inherit (prev) xrootd glfw gbenchmark;
    };
  };
}
