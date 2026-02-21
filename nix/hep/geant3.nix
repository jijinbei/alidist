# GEANT3 v4-5 — Detector simulation for HEP (Fortran)
# Source: geant3.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, gfortran, root, vmc }:

stdenv.mkDerivation rec {
  pname = "geant3";
  version = "4-5";

  src = fetchFromGitHub {
    owner = "vmc-project";
    repo = "geant3";
    rev = "v${version}";
    hash = "sha256-GqlYJEJYLq/dRxBrXvQWVXgRYDmEWIPJ72nSJI0aYVE=";
  };

  nativeBuildInputs = [ cmake ninja gfortran ];
  buildInputs = [ root vmc ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_C_STANDARD=99"
    "-DCMAKE_SKIP_RPATH=TRUE"
  ];

  # gfortran >=10 flags (from geant3.sh) — set via env to avoid cmake quoting issues
  env.FFLAGS = "-fallow-argument-mismatch -fallow-invalid-boz -fno-tree-loop-distribute-patterns";
  env.FCFLAGS = "-fallow-argument-mismatch -fallow-invalid-boz -fno-tree-loop-distribute-patterns";

  postInstall = ''
    # Compatibility symlink (from geant3.sh)
    if [ -d $out/lib64 ] && [ ! -d $out/lib ]; then
      ln -s lib64 $out/lib
    fi
  '';

  meta = with lib; {
    description = "GEANT3 detector simulation (VMC interface)";
    homepage = "https://github.com/vmc-project/geant3";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
