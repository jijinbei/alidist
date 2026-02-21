# ROOT with ALICE-specific overrides
#
# Minimal diff from nixpkgs ROOT — only flags that ALICE actually needs
# beyond what ROOT 6.38 and nixpkgs already provide.
#
# Already ON by ROOT default: roofit, http, root7, pyroot, xrootd
# Already set by nixpkgs:     fftw3=ON, mathmore=ON, vdt=OFF
# Removed in ROOT 6.38:       alien, pgsql, minuit2 (FATAL_ERROR if set)
#
# See docs/implementation.md for the full analysis.
{ root
, pythia
, arrow-cpp
, protobuf
, mold
}:

root.overrideAttrs (old: {
  cmakeFlags = (old.cmakeFlags or []) ++ [
    "-Dpythia8=ON"      # required for physics analysis (GPL)
    "-Darrow=ON"         # required by O2 data format
    "-Dtmva-sofie=ON"   # ML inference without runtime dependency
    "-Dunfold=ON"        # unfolding for physics analysis (GPL)
    "-Dsoversion=ON"     # shared library versioning (ALICE convention)
    "-DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
    "-DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold"
    "-DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold"
  ];

  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
    protobuf  # protoc for tmva-sofie code generation
    mold      # fast linker
  ];

  buildInputs = (old.buildInputs or []) ++ [
    pythia     # pythia8
    arrow-cpp  # Apache Arrow
    protobuf   # libprotobuf for tmva-sofie linking
  ];

  meta = (old.meta or {}) // {
    description = "CERN ROOT with ALICE experiment configuration";
  };
})
