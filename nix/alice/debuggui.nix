# DebugGUI v0.8.0 — ALICE debug GUI (ImGui-based)
# Source: debuggui.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, glfw, freetype, libuv, libGL }:

stdenv.mkDerivation rec {
  pname = "debuggui";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "DebugGUI";
    rev = "v${version}";
    hash = "sha256-kkQ2c6adJCYZq2nKOEl1buzdHMURw4Po8mypCxfVv3g=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ glfw freetype libuv libGL ];

  cmakeFlags = [
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  ];

  # Platform-specific defines (from debuggui.sh)
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isLinux
    "-DIMGUI_IMPL_OPENGL_LOADER_GL3W -DTRACY_NO_FILESELECTOR -DNO_PARALLEL_SORT";

  meta = with lib; {
    description = "ALICE debug GUI based on ImGui";
    homepage = "https://github.com/AliceO2Group/DebugGUI";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
