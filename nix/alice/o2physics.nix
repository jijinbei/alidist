# O2Physics — ALICE physics analysis framework
# Source: o2physics.sh
#
# O2Physics depends on O2. However, O2's installed O2Config.cmake includes
# O2Dependencies.cmake which re-finds ALL of O2's own dependencies via
# find_package(). Therefore O2Physics must have all of O2's deps available.
#
# Source is provided as a flake input (managed by flake.lock).
# Update with: nix flake lock --update-input o2physics-src
{ lib, stdenv, cmake, ninja, python3, pkg-config, src
# O2 + O2's explicit deps from o2physics.sh
, o2, onnxruntime, kfparticle, libjalien-o2, fastjet, fastjet-contrib
# Arrow with Gandiva
, arrow-cpp
# O2Dependencies.cmake re-finds ALL of these (Layer 1)
, root
# Layer 2a
, vmc, vc, fairlogger, common-o2, libinfologger
# Layer 2b
, fairmq, geant4, geant3, configuration, monitoring, bookkeeping-api
# Layer 2c
, geant4_vmc, mcsteplogger, fairroot, debuggui, jalien-root, vgm
# nixpkgs deps re-found by O2Dependencies.cmake
, boost, fmt, zeromq, curl, protobuf, gsl, openssl, onetbb
, freetype, libpng, xz, libxml2, fftw, fftwSinglePrec, nlohmann_json, zlib
, abseil-cpp, libuv, rapidjson, cgal, microsoft-gsl
, flatbuffers, hepmc3, grpc
, xrootd, glfw, gbenchmark
, llvmPackages
}:

stdenv.mkDerivation {
  pname = "o2physics";
  version = src.shortRev or src.rev or "dev";

  inherit src;

  nativeBuildInputs = [ cmake ninja python3 protobuf pkg-config llvmPackages.clang-unwrapped ];
  buildInputs = [
    # O2 itself
    o2
    # O2's direct deps from o2physics.sh
    onnxruntime kfparticle libjalien-o2 fastjet fastjet-contrib
    # Arrow with Gandiva — O2Dependencies.cmake re-finds these
    arrow-cpp
    # Layer 1
    root
    # Layer 2a — re-found by O2Dependencies.cmake
    vmc vc fairlogger common-o2 libinfologger
    # Layer 2b
    fairmq geant4 geant3 configuration monitoring bookkeeping-api
    # Layer 2c
    geant4_vmc mcsteplogger kfparticle fairroot debuggui jalien-root vgm
    # nixpkgs — re-found by O2Dependencies.cmake
    boost fmt zeromq curl protobuf gsl openssl onetbb
    freetype libpng xz libxml2 fftw fftwSinglePrec nlohmann_json zlib
    abseil-cpp libuv rapidjson cgal microsoft-gsl
    flatbuffers hepmc3 grpc
    xrootd glfw gbenchmark
    # LLVM — Gandiva's CMake needs LLVM
    llvmPackages.llvm llvmPackages.llvm.dev
  ];


  # FFTW3f cmake wrapper — same as o2.nix (nixpkgs config lacks FFTW3::fftw3f target)
  preConfigure = ''
    mkdir -p cmake-fftw3f
    cat > cmake-fftw3f/FFTW3fConfig.cmake << 'FFTW_EOF'
    include("${fftwSinglePrec.dev}/lib/cmake/fftw3/FFTW3fConfig.cmake")
    if(NOT TARGET FFTW3::fftw3f)
      add_library(FFTW3::fftw3f SHARED IMPORTED)
      set_target_properties(FFTW3::fftw3f PROPERTIES
        IMPORTED_LOCATION "${fftwSinglePrec.out}/lib/libfftw3f.so"
        INTERFACE_INCLUDE_DIRECTORIES "${fftwSinglePrec.dev}/include")
    endif()
    FFTW_EOF
    cmakeFlagsArray+=("-DFFTW3f_DIR=$PWD/cmake-fftw3f")
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_IGNORE_PATH=/opt/homebrew/include"
    # Explicit hints for O2Dependencies.cmake find_package() calls
    "-DONNXRuntime_DIR=${onnxruntime}"
    "-Dfjcontrib_ROOT=${fastjet-contrib}"
    "-DlibjalienO2_ROOT=${libjalien-o2}"
    "-DLibUV_ROOT=${libuv}"
    "-DXROOTD_DIR=${xrootd}"
    # Arrow/Gandiva
    "-DArrow_DIR=${arrow-cpp}/lib/cmake/Arrow"
    "-DGandiva_DIR=${arrow-cpp}/lib/cmake/Gandiva"
    # LLVM/Clang — Gandiva's CMake needs these (o2physics.sh lines 40, 44-45)
    "-DLLVM_DIR=${llvmPackages.llvm.dev}/lib/cmake/llvm"
    "-DLLVM_ROOT=${llvmPackages.llvm.dev}"
    "-DCLANG_EXECUTABLE=${llvmPackages.clang-unwrapped}/bin/clang"
    "-DLLVM_LINK_EXECUTABLE=${llvmPackages.llvm}/bin/llvm-link"
    "-DCURL_ROOT=${curl.dev}"
    "-DFFTW3f_DIR=${fftwSinglePrec.dev}/lib/cmake/fftw3"
  ];

  # O2Dependencies.cmake re-finds ROOT; some targets need these include paths
  ROOT_INCLUDE_PATH = lib.concatStringsSep ":" [
    "${boost.dev}/include"
    "${openssl.dev}/include"
  ];

  meta = with lib; {
    description = "ALICE physics analysis code for Run 3";
    homepage = "https://github.com/AliceO2Group/O2Physics";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
