# libInfoLogger v2.10.0 — ALICE InfoLogger library
# Source: libinfologger.sh
#
# CMakeLists.txt uses ExternalProject to git-clone Common for headers.
# We pre-fetch Common and patch to use a local source instead.
{ lib, stdenv, fetchFromGitHub, cmake, ninja, boost, git }:

let
  common-src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "Common";
    rev = "v1.6.3";
    hash = "sha256-3C8Km51aQ1rHSTmtCgvh1mNy9vDiueftEIICPFFCnQU=";
  };
in
stdenv.mkDerivation rec {
  pname = "libinfologger";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "InfoLogger";
    rev = "v${version}";
    hash = "sha256-OrPITCHLbnNGuLPM2yl86szOwTJ6b1vdsVOSqsQE6f0=";
  };

  nativeBuildInputs = [ cmake ninja git ];
  buildInputs = [ boost ];

  # Patch out the ExternalProject git clone:
  # Replace the GIT_REPOSITORY with a SOURCE_DIR pointing to our pre-fetched source
  postPatch = ''
    sed -i '/externalproject_add (Common-standalone/,/^)/c\
    externalproject_add (Common-standalone\
      SOURCE_DIR "${common-src}"\
      BUILD_COMMAND ""\
      CONFIGURE_COMMAND ""\
      TEST_COMMAND ""\
      INSTALL_COMMAND ""\
    )' CMakeLists.txt
  '';

  cmakeFlags = [
    "-DINFOLOGGER_BUILD_LIBONLY=1"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];

  meta = with lib; {
    description = "ALICE InfoLogger library (lib-only build)";
    homepage = "https://github.com/AliceO2Group/InfoLogger";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
