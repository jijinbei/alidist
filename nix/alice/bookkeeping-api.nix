# bookkeeping-api v1.9.2 — ALICE Bookkeeping C++ client
# Source: bookkeeping-api.sh
# Builds from cxx-client subdirectory of the Bookkeeping repo
{ lib, stdenv, fetchFromGitHub, cmake, grpc, protobuf, openssl }:

stdenv.mkDerivation rec {
  pname = "bookkeeping-api";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "Bookkeeping";
    # Tag format: @aliceo2/bookkeeping@<version>
    rev = "@aliceo2/bookkeeping@${version}";
    hash = "sha256-I9OtBKba9G1E8vBukVbuQUrR9znbUg16iJDUOVklnv4=";
  };

  sourceRoot = "${src.name}/cxx-client";

  nativeBuildInputs = [ cmake ];
  buildInputs = [ grpc protobuf openssl ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    description = "ALICE Bookkeeping C++ client library";
    homepage = "https://github.com/AliceO2Group/Bookkeeping";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
