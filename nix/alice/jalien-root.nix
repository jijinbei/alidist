# JAliEn-ROOT 0.7.16 — JAliEn ROOT plugin
# Source: jalien-root.sh
{ lib, stdenv, fetchgit, cmake, ninja, root, openssl, zlib, xrootd, libwebsockets, libuv, json_c, alice-grid-utils }:

stdenv.mkDerivation rec {
  pname = "jalien-root";
  version = "0.7.16";

  src = fetchgit {
    url = "https://gitlab.cern.ch/jalien/jalien-root.git";
    rev = version;
    hash = "sha256-QsV0wfx1LtddHKuMlDTfrNWN0aFemKWXeMr0V+xOcjc=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ root openssl zlib xrootd libwebsockets libuv json_c alice-grid-utils ];

  # Patch FindXROOTD.cmake: version detection is broken for XRootD 5.x,
  # incorrectly sets OLDPACK=TRUE and looks for nonexistent v4 library names.
  # Fix: force OLDPACK=FALSE and use modern XrdUtils/XrdCl libraries.
  postPatch = ''
    sed -i '/set(XROOTD_OLDPACK TRUE)/d' cmake/modules/FindXROOTD.cmake
    sed -i 's|if (''${xrdversnum} LESS 300010000)|if (FALSE)|' cmake/modules/FindXROOTD.cmake
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Debug"
    "-DROOTSYS=${root}"
    "-DOPENSSL_ROOT_DIR=${openssl.dev}"
    "-DOPENSSL_CRYPTO_LIBRARY=${openssl.out}/lib/libcrypto.so"
    "-DOPENSSL_SSL_LIBRARY=${openssl.out}/lib/libssl.so"
    "-DZLIB_ROOT=${zlib}"
    "-DXROOTD_ROOT_DIR=${xrootd}"
    "-DLWS=${libwebsockets}"
    "-DALICE_GRID_UTILS_ROOT=${alice-grid-utils}"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "JAliEn ROOT plugin for ALICE Grid access";
    homepage = "https://gitlab.cern.ch/jalien/jalien-root";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
