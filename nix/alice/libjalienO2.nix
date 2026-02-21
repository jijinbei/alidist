# libjalienO2 0.2.3 — JAliEn O2 interface library
# Source: libjalien-o2.sh
{ lib, stdenv, fetchgit, cmake, openssl }:

stdenv.mkDerivation rec {
  pname = "libjalien-o2";
  version = "0.2.3";

  src = fetchgit {
    url = "https://gitlab.cern.ch/jalien/libjalieno2.git";
    rev = version;
    hash = "sha256-LptoQyJTU5KvhN3/sjdK+lWpEUNoPTfS3gWQgCLlF8E=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];

  # Fix missing <algorithm> include for GCC 15
  postPatch = ''
    sed -i '1i #include <algorithm>' src/TAlienUserAgent.cxx
  '';

  cmakeFlags = [
    "-DOPENSSL_ROOT_DIR=${openssl.dev}"
    "-DOPENSSL_CRYPTO_LIBRARY=${openssl.out}/lib/libcrypto.so"
    "-DOPENSSL_SSL_LIBRARY=${openssl.out}/lib/libssl.so"
  ];

  meta = with lib; {
    description = "JAliEn interface library for ALICE O2";
    homepage = "https://gitlab.cern.ch/jalien/libjalieno2";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
