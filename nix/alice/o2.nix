# O2 — ALICE O2 framework (AliceO2Group/AliceO2)
# Source: o2.sh
#
# This is the core ALICE O2 framework. It depends on nearly all Layer 2 packages.
# GPU support (CUDA/HIP/OpenCL) is disabled for the Nix build.
#
# Source is provided as a flake input (managed by flake.lock).
# Update with: nix flake lock --update-input o2-src
{ lib, stdenv, cmake, ninja, pkg-config, src
, root, fairroot, fairmq, fairlogger, vmc, vc
, geant3, geant4, geant4_vmc, mcsteplogger
, configuration, monitoring, common-o2, libinfologger
, debuggui, jalien-root, libjalien-o2, bookkeeping-api
, mlmodels, onnxruntime, kfparticle
, boost, fmt, zeromq, curl, protobuf, gsl, openssl
, freetype, libpng, xz, libxml2, fftw, fftwSinglePrec, nlohmann_json, zlib
, abseil-cpp, libuv, rapidjson, cgal, microsoft-gsl
, arrow-cpp, flatbuffers, hepmc3, fastjet
, python3, onetbb, grpc, xrootd, glfw, gbenchmark
, llvmPackages
}:

stdenv.mkDerivation {
  pname = "o2";
  version = src.shortRev or src.rev or "dev";

  inherit src;

  nativeBuildInputs = [ cmake ninja python3 protobuf pkg-config llvmPackages.clang-unwrapped ];
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
    boost fmt zeromq curl protobuf gsl openssl onetbb
    freetype libpng xz libxml2 fftw fftwSinglePrec nlohmann_json zlib
    abseil-cpp libuv rapidjson cgal microsoft-gsl
    arrow-cpp flatbuffers hepmc3 fastjet grpc
    # XRootD — RECOMMENDED by O2Dependencies.cmake (o2.sh line 241)
    xrootd
    # GLFW — RECOMMENDED (for DebugGUI integration)
    glfw
    # Google Benchmark — used unconditionally in Framework/Core benchmarks
    gbenchmark
    # LLVM — needed at configure time for Gandiva (GandivaConfig.cmake → find_dependency(LLVMAlt))
    llvmPackages.llvm llvmPackages.llvm.dev
  ];

  # CMake 4.x fixes for O2 source code
  postPatch = ''
    # Fix rANS + DataFormats: target_compile_options with empty target variable
    # when BUILD_TESTING=OFF. CMake 4.x treats empty ''${VAR} as literal "PRIVATE".
    sed -i -E 's/^( *)target_compile_options\(\$\{(TEST_[A-Z_]+)\} (PRIVATE.*)\)/\1if(TARGET ''${\2})\n\1  target_compile_options(''${\2} \3)\n\1endif()/' \
      Utilities/rANS/CMakeLists.txt \
      DataFormats/Detectors/Common/CMakeLists.txt

    # Fix shebang: /bin/bash doesn't exist in Nix sandbox
    patchShebangs cmake/rootcling_wrapper.sh.in

    # ROOT 6.38: TGenericClassInfo::AdoptMemberStreamer removed.
    # Use TClass::GetClass()->AdoptMemberStreamer() instead.
    sed -i 's|ROOT::GenerateInitInstance((o2::tpc::CalArray<o2::tpc::PadFlags> \*)nullptr)->AdoptMemberStreamer|TClass::GetClass<o2::tpc::CalArray<o2::tpc::PadFlags>>()->AdoptMemberStreamer|' \
      Detectors/TPC/baserecsim/src/TPCFlagsMemberCustomStreamer.cxx
    sed -i '/#include <TMemberStreamer.h>/a #include <TClass.h>' \
      Detectors/TPC/baserecsim/src/TPCFlagsMemberCustomStreamer.cxx
  '';

  # Pre-generate GPU parameters JSON — CMake 4.x execute_process + string(JSON)
  # interaction produces empty/unreadable JSON from csv_to_json.sh in sandbox
  preConfigure = ''
    bash GPU/GPUTracking/Definitions/Parameters/csv_to_json.sh \
      GPU/GPUTracking/Definitions/Parameters/GPUParameters.csv \
      > gpu_params.json
    cmakeFlagsArray+=("-DGPUCA_OVERRIDE_PARAMETER_FILE=$PWD/gpu_params.json")

    # Create FFTW3::fftw3f IMPORTED target — nixpkgs fftw-single only sets variables,
    # not modern cmake targets. Provide a wrapper config that creates the target.
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
    "-DCMAKE_BUILD_TYPE=RELWITHDEBINFO"
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
    "-DGandiva_DIR=${arrow-cpp}/lib/cmake/Gandiva"
    # LLVM/Clang — required by Gandiva's FindLLVMAlt.cmake (see o2.sh lines 258-259)
    # GandivaConfig.cmake temporarily sets CMAKE_MODULE_PATH to its own dir for
    # find_dependency(LLVMAlt); if LLVMAlt fails, return() skips MODULE_PATH restore,
    # breaking all subsequent find_package(MODULE) calls. So clang MUST be provided.
    "-DLLVM_DIR=${llvmPackages.llvm.dev}/lib/cmake/llvm"
    "-DCLANG_EXECUTABLE=${llvmPackages.clang-unwrapped}/bin/clang"
    "-DLLVM_LINK_EXECUTABLE=${llvmPackages.llvm}/bin/llvm-link"
    "-DCURL_ROOT=${curl.dev}"
    "-DLibUV_ROOT=${libuv}"
    "-DONNXRuntime_DIR=${onnxruntime}"
    "-Dfjcontrib_ROOT=${fastjet}"
    # XRootD — O2's FindXRootD.cmake uses XROOTD_DIR hint (o2.sh line 241)
    "-DXROOTD_DIR=${xrootd}"
    "-DFFTW3f_DIR=${fftwSinglePrec.dev}/lib/cmake/fftw3"
  ];

  # O2 needs VMCWORKDIR at build time
  VMCWORKDIR = "${src}/share";

  # O2 sets ROOT_INCLUDE_PATH for includes from dependencies
  ROOT_INCLUDE_PATH = lib.concatStringsSep ":" [
    "${boost.dev}/include"
    "${openssl.dev}/include"
  ];

  meta = with lib; {
    description = "ALICE O2 software framework for Run 3";
    homepage = "https://github.com/AliceO2Group/AliceO2";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
