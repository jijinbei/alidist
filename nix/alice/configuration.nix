# Configuration v2.8.0 — ALICE O2 Configuration library
# Source: configuration.sh
{ lib, stdenv, fetchFromGitHub, cmake, boost, curl, ppconsul }:

stdenv.mkDerivation rec {
  pname = "configuration";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "Configuration";
    rev = "v${version}";
    hash = "sha256-BIEFuWbzGql4U2uwClu25tEA+FBtjeUsF1Co8I+mYd4=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost curl ppconsul ];

  cmakeFlags = [
    "-Dppconsul_DIR=${ppconsul}/cmake"
  ];

  meta = with lib; {
    description = "ALICE O2 Configuration library";
    homepage = "https://github.com/AliceO2Group/Configuration";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
