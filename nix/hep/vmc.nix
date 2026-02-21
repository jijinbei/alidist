# VMC v2-1 — Virtual Monte Carlo
# Source: vmc.sh
{ lib, stdenv, fetchFromGitHub, cmake, root }:

stdenv.mkDerivation rec {
  pname = "vmc";
  version = "2-1";

  src = fetchFromGitHub {
    owner = "vmc-project";
    repo = "vmc";
    rev = "v${version}";
    hash = "sha256-1bqQNCwcc6j+ATOaPKwmGefxAaP732bcbph69JdBnHM=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ root ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_CXX_STANDARD=20"
  ];

  postInstall = ''
    # Backward compatibility symlinks (from vmc.sh)
    if [ -f $out/lib/libVMCLibrary.so ]; then
      ln -sf libVMCLibrary.so $out/lib/libVMC.so
    fi
  '';

  meta = with lib; {
    description = "Virtual Monte Carlo (VMC) interface";
    homepage = "https://github.com/vmc-project/vmc";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
