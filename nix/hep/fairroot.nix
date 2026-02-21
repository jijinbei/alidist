# FairRoot v18.4.9-alice3 — Simulation/analysis framework (ALICE fork)
# Source: fairroot.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja
, root, vmc, boost, protobuf, fairlogger, faircmakemodules
, geant3, geant4, fmt
}:

stdenv.mkDerivation rec {
  pname = "fairroot";
  version = "18.4.9-alice3";

  src = fetchFromGitHub {
    owner = "alisw";
    repo = "FairRoot";
    rev = "v${version}";
    hash = "sha256-R9y+ZYvEQ+JdrCefYpukaRmcOiDekVzM+u808z6RiFk=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    root vmc boost protobuf fairlogger faircmakemodules
    geant3 geant4 fmt
  ];

  cmakeFlags = [
    "-DROOTSYS=${root}"
    "-DROOT_CONFIG_SEARCHPATH=${root}/bin"
    "-DGeant3_DIR=${geant3}"
    "-DGeant4_DIR=${geant4}/lib/Geant4-11.2.0"
    "-DBUILD_MBS=OFF"
    "-DDISABLE_GO=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DFAIRROOT_MODULAR_BUILD=ON"
    "-DCMAKE_DISABLE_FIND_PACKAGE_yaml-cpp=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_CXX_STANDARD=20"
    "-DProtobuf_PROTOC_EXECUTABLE=${protobuf}/bin/protoc"
  ];

  # FairRoot requires SIMPATH to be unset (from fairroot.sh)
  preConfigure = ''
    unset SIMPATH
  '';

  meta = with lib; {
    description = "FairRoot simulation/analysis framework (ALICE fork)";
    homepage = "https://github.com/alisw/FairRoot";
    license = licenses.lgpl3Plus;
    platforms = platforms.unix;
  };
}
