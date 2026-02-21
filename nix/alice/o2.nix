# O2 — ALICE O2 framework (AliceO2Group/AliceO2)
# Source: o2.sh
#
# This is the core ALICE O2 framework. It depends on nearly all Layer 2 packages.
# GPU support (CUDA/HIP/OpenCL) is disabled for the Nix build.
{ lib, stdenv, fetchFromGitHub, cmake, ninja
, root, fairroot, fairmq, fairlogger, vmc, vc
, geant3, geant4, geant4_vmc, mcsteplogger
, configuration, monitoring, common-o2, libinfologger
, debuggui, jalien-root, libjalien-o2, bookkeeping-api
, mlmodels, onnxruntime, kfparticle
, boost, fmt, zeromq, curl, protobuf, gsl, openssl
, freetype, libpng, xz, libxml2, fftw, nlohmann_json, zlib
, abseil-cpp, libuv, rapidjson, cgal, microsoft-gsl
, arrow-cpp, flatbuffers, hepmc3, fastjet
, python3
}:

stdenv.mkDerivation rec {
  pname = "o2";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "AliceO2";
    rev = "dev";
    hash = "sha256-aVSLhTNtBp4s/1bxisbqFm1Bod29t8sSKPMlHlK0eEs=";
  };

  nativeBuildInputs = [ cmake ninja python3 protobuf ];
  buildInputs = [
    # Layer 1
    root
    # Layer 2a
    vmc vc fairlogger common-o2 libinfologger mlmodels
    # Layer 2b
    fairmq geant4 geant3 configuration monitoring
    libjalien-o2 bookkeeping-api
    # Layer 2c
    geant4_vmc mcsteplogger kfparticle fairroot
    debuggui jalien-root onnxruntime
    # nixpkgs
    boost fmt zeromq curl protobuf gsl openssl
    freetype libpng xz libxml2 fftw nlohmann_json zlib
    abseil-cpp libuv rapidjson cgal microsoft-gsl
    arrow-cpp flatbuffers hepmc3 fastjet
  ];

  cmakeFlags = [
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_CXX_STANDARD=20"
    # Disable GPU (not available in Nix sandbox)
    "-DENABLE_CUDA=OFF"
    "-DENABLE_HIP=OFF"
    "-DENABLE_OPENCL=OFF"
    "-DCMAKE_IGNORE_PATH=/opt/homebrew/include"
    # Point to dependencies
    "-DlibjalienO2_ROOT=${libjalien-o2}"
    "-DJALIEN_ROOT_ROOT=${jalien-root}"
    "-DArrow_DIR=${arrow-cpp}/lib/cmake/Arrow"
  ];

  # O2 needs VMCWORKDIR at build time
  VMCWORKDIR = "${src}/share";

  meta = with lib; {
    description = "ALICE O2 software framework for Run 3";
    homepage = "https://github.com/AliceO2Group/AliceO2";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
