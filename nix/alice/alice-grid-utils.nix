# Alice-GRID-Utils 0.0.7 — Header-only ALICE Grid utilities
# Source: alice-grid-utils.sh
{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "alice-grid-utils";
  version = "0.0.7";

  src = fetchgit {
    url = "https://gitlab.cern.ch/jalien/alice-grid-utils.git";
    rev = version;
    hash = "sha256-4+3xz7xbgJ2zNeK0FQZ54l411eoRiVBfYw5TgvqPSjs=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/include
    cp -v *.h $out/include/
  '';

  meta = with lib; {
    description = "Header-only ALICE Grid utilities";
    homepage = "https://gitlab.cern.ch/jalien/alice-grid-utils";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
