# MCStepLogger v0.6.1 — MC step logging for ALICE
# Source: mcsteplogger.sh
{ lib, stdenv, fetchFromGitHub, cmake, root, vmc, boost }:

stdenv.mkDerivation rec {
  pname = "mcsteplogger";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "VMCStepLogger";
    rev = "v${version}";
    hash = "sha256-Os+4o4wb/7E9YhFJeklurpi2txqomPh7IQlxnkqwf5g=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ root vmc boost ];

  # Fix missing <cmath> includes for GCC 15
  postPatch = ''
    sed -i '1i #include <cmath>' MCStepLogger/src/BasicMCAnalysis.cxx MCStepLogger/src/SimpleStepAnalysis.cxx || true
  '';

  cmakeFlags = [
    "-DROOT_DIR=${root}/share/root/cmake"
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  # Disable -Werror to handle format-security warnings in MCReplayEngine
  NIX_CFLAGS_COMPILE = "-Wno-error=format-security";

  meta = with lib; {
    description = "Monte Carlo step logger for ALICE simulations";
    homepage = "https://github.com/AliceO2Group/VMCStepLogger";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
