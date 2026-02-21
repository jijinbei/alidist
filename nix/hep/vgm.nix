# vgm v5-3 — Virtual Geometry Model
# Source: vgm.sh
{ lib, stdenv, fetchFromGitHub, cmake, root, geant4 }:

stdenv.mkDerivation rec {
  pname = "vgm";
  version = "5-3";

  src = fetchFromGitHub {
    owner = "vmc-project";
    repo = "vgm";
    rev = "v${version}";
    hash = "sha256-HrqLGH8Ee/gPYP2pY2F83gj3BL1b/mikd7oeoCHAys4=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ root geant4 ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Virtual Geometry Model for detector simulations";
    homepage = "https://github.com/vmc-project/vgm";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
