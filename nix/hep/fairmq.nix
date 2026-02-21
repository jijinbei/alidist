# FairMQ v1.10.1 — Message queue framework for FairRoot
# Source: fairmq.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, boost, zeromq, fmt, fairlogger, faircmakemodules }:

stdenv.mkDerivation rec {
  pname = "fairmq";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "FairRootGroup";
    repo = "FairMQ";
    rev = "v${version}";
    hash = "sha256-hDFB8uBu+UoWp/sB30OTpowaFUekFm+CJRbptbXSwfU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ boost zeromq fmt fairlogger faircmakemodules ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DDISABLE_COLOR=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Lightweight and fast C++ message queue framework";
    homepage = "https://github.com/FairRootGroup/FairMQ";
    license = licenses.lgpl3Plus;
    platforms = platforms.unix;
  };
}
