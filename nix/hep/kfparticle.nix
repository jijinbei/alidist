# KFParticle v1.1-alice9 — Kalman Filter particle reconstruction (ALICE fork)
# Source: kfparticle.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, root, vc }:

stdenv.mkDerivation rec {
  pname = "kfparticle";
  version = "1.1-alice9";

  src = fetchFromGitHub {
    owner = "alisw";
    repo = "KFParticle";
    rev = "v${version}";
    hash = "sha256-zxlpHMs82ZdYs9fjbWDHt7aeXo7ZIw3bSy077hEeVrE=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ root vc ];

  cmakeFlags = [
    "-DVc_INCLUDE_DIR=${vc}/include"
    "-DVc_LIBRARIES=${vc}/lib/libVc.a"
    "-DFIXTARGET=FALSE"
  ];

  meta = with lib; {
    description = "Kalman Filter based particle finder (ALICE fork)";
    homepage = "https://github.com/alisw/KFParticle";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
