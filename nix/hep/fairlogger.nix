# FairLogger v2.3.1 — Logging library for FairRoot
# Source: fairlogger.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, fmt }:

stdenv.mkDerivation rec {
  pname = "fairlogger";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "FairRootGroup";
    repo = "FairLogger";
    rev = "v${version}";
    hash = "sha256-eK2gBVO7+WEd4v1LmgNTs+vYLFaqT8wkgPssqFBOL3w=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ fmt ];

  cmakeFlags = [
    "-DPROJECT_GIT_VERSION=${version}"
    "-DBUILD_TESTING=OFF"
    "-DDISABLE_COLOR=ON"
    "-DUSE_EXTERNAL_FMT=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Lightweight and fast C++ logging library used in FairRoot";
    homepage = "https://github.com/FairRootGroup/FairLogger";
    license = licenses.lgpl3Plus;
    platforms = platforms.unix;
  };
}
