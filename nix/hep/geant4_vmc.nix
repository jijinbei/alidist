# GEANT4_VMC v6-6-update1-p3 — Geant4 VMC interface
# Source: geant4_vmc.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, root, vmc, geant4, vgm }:

stdenv.mkDerivation rec {
  pname = "geant4_vmc";
  version = "6-6-update1-p3";

  src = fetchFromGitHub {
    owner = "vmc-project";
    repo = "geant4_vmc";
    rev = "v${version}";
    hash = "sha256-NRt+ITVECxNTUNpyEZ/L2Xyur7PI2ZCoON1pdV0K2Hw=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ root vmc geant4 vgm ];

  cmakeFlags = [
    "-DGeant4VMC_USE_VGM=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DGeant4VMC_BUILD_EXAMPLES=OFF"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Geant4 VMC interface package";
    homepage = "https://github.com/vmc-project/geant4_vmc";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
