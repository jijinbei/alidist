# MLModels 20220530 — Pre-trained ML models for ALICE
# Source: mlmodels.sh (data-only package, simple rsync)
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mlmodels";
  version = "20220530";

  src = fetchFromGitHub {
    owner = "alisw";
    repo = "MLModels";
    rev = version;
    hash = "sha256-qp16ZWR0dRYiy8u4DvvkomCYuKKIgpnyMSulh98hydg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/MLModels
    cp -r . $out/share/MLModels/
  '';

  meta = with lib; {
    description = "Pre-trained ML models for ALICE experiment";
    homepage = "https://github.com/alisw/MLModels";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
