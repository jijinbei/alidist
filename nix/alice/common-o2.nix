# Common-O2 v1.6.4 — ALICE common utilities
# Source: common-o2.sh
{ lib, stdenv, fetchFromGitHub, cmake, boost }:

stdenv.mkDerivation rec {
  pname = "common-o2";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "Common";
    rev = "v${version}";
    hash = "sha256-RNZdnwX6qMh4ByKpJqf2iiPzLiJwpquz7LX6ZJhTuzI=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost ];

  cmakeFlags = [
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];

  meta = with lib; {
    description = "ALICE common utilities library";
    homepage = "https://github.com/AliceO2Group/Common";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
