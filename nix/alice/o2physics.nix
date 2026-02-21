# O2Physics — ALICE physics analysis framework
# Source: o2physics.sh
#
# Depends on O2 and a few additional packages.
#
# Source is provided as a flake input (managed by flake.lock).
# Update with: nix flake lock --update-input o2physics-src
{ lib, stdenv, cmake, ninja, src
, o2, onnxruntime, kfparticle, libjalien-o2
, fastjet, libuv
}:

stdenv.mkDerivation {
  pname = "o2physics";
  version = src.shortRev or src.rev or "dev";

  inherit src;

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    o2 onnxruntime kfparticle libjalien-o2 fastjet libuv
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_IGNORE_PATH=/opt/homebrew/include"
    "-DONNXRuntime_DIR=${onnxruntime}"
    "-Dfjcontrib_ROOT=${fastjet}"
    "-DlibjalienO2_ROOT=${libjalien-o2}"
    "-DLibUV_ROOT=${libuv}"
  ];

  meta = with lib; {
    description = "ALICE physics analysis code for Run 3";
    homepage = "https://github.com/AliceO2Group/O2Physics";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
