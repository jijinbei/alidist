# Ppconsul v0.2.3-alice3 — C++ client for Consul (ALICE fork)
# Source: ppconsul.sh
{ lib, stdenv, fetchFromGitHub, cmake, boost, curl }:

stdenv.mkDerivation rec {
  pname = "ppconsul";
  version = "0.2.3-alice3";

  src = fetchFromGitHub {
    owner = "alisw";
    repo = "ppconsul";
    rev = "v${version}";
    hash = "sha256-3iiNoD256RSYVBjoZ+3UevJZe/19Ra5KU0KA9jU3VG0=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost curl ];

  # Fix missing <cstdint> include for GCC 15 / C++20
  postPatch = ''
    sed -i '1i #include <cstdint>' ext/json11/json11.cpp
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  # Fix broken .pc file paths (prefix + absolute path = double slash)
  postFixup = ''
    if [ -f $out/lib/pkgconfig/ppconsul.pc ]; then
      sed -i "s|''${prefix}/''${out}|''${out}|g; s|''${exec_prefix}/''${out}|''${out}|g" $out/lib/pkgconfig/ppconsul.pc
      sed -i "s|=\(.*\)//nix|=\1/nix|g" $out/lib/pkgconfig/ppconsul.pc
    fi
  '';

  meta = with lib; {
    description = "C++ client for Consul (ALICE fork)";
    homepage = "https://github.com/alisw/ppconsul";
    license = licenses.boost;
    platforms = platforms.unix;
  };
}
