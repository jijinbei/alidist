# O2Physics — ALICE physics analysis framework
# Source: o2physics.sh
#
# Depends on O2 and a few additional packages.
{ lib, stdenv, fetchFromGitHub, cmake, ninja
, o2, onnxruntime, kfparticle, libjalien-o2
, fastjet
}:

stdenv.mkDerivation rec {
  pname = "o2physics";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "O2Physics";
    rev = "master";
    hash = "sha256-K2UlNC3L4E8s94ZPhrPkMQ8Z0Qz/5UVsd/VnP7v+fwk=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    o2 onnxruntime kfparticle libjalien-o2 fastjet
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_IGNORE_PATH=/opt/homebrew/include"
  ];

  meta = with lib; {
    description = "ALICE physics analysis code for Run 3";
    homepage = "https://github.com/AliceO2Group/O2Physics";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
