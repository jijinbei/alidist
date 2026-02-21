# GEANT4 v11.2.0-alice1 — Particle physics simulation toolkit (ALICE fork)
# Source: geant4.sh
# Data files are provided separately via geant4-data.nix (like nixpkgs)
{ lib, stdenv, fetchFromGitHub, cmake, xercesc, zlib, expat }:

stdenv.mkDerivation rec {
  pname = "geant4";
  version = "11.2.0-alice1";

  src = fetchFromGitHub {
    owner = "alisw";
    repo = "geant4";
    rev = "v${version}";
    hash = "sha256-HOIJ06Ilspnxqy8CTsHs57StHdBQNRfqwm9ggCfik70=";
  };

  nativeBuildInputs = [ cmake ];
  # Propagate deps so consumers of Geant4Config.cmake find them automatically
  propagatedBuildInputs = [ xercesc zlib expat ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-fPIC"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DGEANT4_BUILD_TLS_MODEL:STRING=global-dynamic"
    "-DGEANT4_ENABLE_TESTING=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DGEANT4_INSTALL_EXAMPLES=OFF"
    "-DGEANT4_BUILD_MULTITHREADED=OFF"
    "-DCMAKE_STATIC_LIBRARY_CXX_FLAGS=-fPIC"
    "-DCMAKE_STATIC_LIBRARY_C_FLAGS=-fPIC"
    "-DGEANT4_USE_G3TOG4=ON"
    "-DGEANT4_INSTALL_DATA=OFF"
    "-DGEANT4_USE_SYSTEM_EXPAT=ON"
    "-DGEANT4_USE_GDML=ON"
    "-DGEANT4_USE_SYSTEM_ZLIB=ON"
    "-DGEANT4_BUILD_CXXSTD=20"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];

  postInstall = ''
    # Remove cache file to prevent issues with relocated installs (from geant4.sh)
    find $out -name Geant4PackageCache.cmake -delete || true
  '';

  meta = with lib; {
    description = "Toolkit for simulation of particle passage through matter (ALICE fork)";
    homepage = "https://github.com/alisw/geant4";
    license = licenses.free; # Geant4 Software License
    platforms = platforms.unix;
  };
}
