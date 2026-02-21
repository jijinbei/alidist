# Vc 1.4.5 — SIMD vector classes for C++
# Source: vc.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja }:

stdenv.mkDerivation rec {
  pname = "vc";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "VcDevel";
    repo = "Vc";
    rev = version;
    hash = "sha256-A2qUzjXv50unFcoZp2nRVinkph+CoHyiU7AgOphDphM=";
  };

  nativeBuildInputs = [ cmake ninja ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  meta = with lib; {
    description = "SIMD vector classes for C++";
    homepage = "https://github.com/VcDevel/Vc";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
