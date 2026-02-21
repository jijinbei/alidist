# FairCMakeModules v1.0.0
# Source: faircmakemodules.sh
{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "faircmakemodules";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "FairRootGroup";
    repo = "FairCMakeModules";
    rev = "v${version}";
    hash = "sha256-nAy2FTeLuqaaUTXZfB9WkIzBNKEhx36wjqSiBQKZ7Og=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];

  meta = with lib; {
    description = "CMake modules used in FairRoot";
    homepage = "https://github.com/FairRootGroup/FairCMakeModules";
    license = licenses.lgpl3Plus;
    platforms = platforms.unix;
  };
}
