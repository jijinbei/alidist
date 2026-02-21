# ONNXRuntime v1.22.0 — ML inference runtime
# Source: onnxruntime.sh
#
# ONNXRuntime has many vendored dependencies fetched via CMake FETCHCONTENT.
# For now we allow network access during build (FETCHCONTENT_FULLY_DISCONNECTED=OFF).
# TODO: Pre-fetch all vendored deps for a fully hermetic build.
{ lib, stdenv, fetchFromGitHub, cmake, ninja, python3
, protobuf, re2, boost, abseil-cpp, microsoft-gsl, flatbuffers, eigen
, nlohmann_json
}:

stdenv.mkDerivation rec {
  pname = "onnxruntime";
  version = "1.22.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "onnxruntime";
    rev = "v${version}";
    hash = "sha256-FpTIRlcLYehF5teB3oAXEXt/fQpDVpq41jQ2Tmg6Wnw=";
  };

  sourceRoot = "${src.name}/cmake";

  nativeBuildInputs = [ cmake ninja python3 protobuf ];
  buildInputs = [
    protobuf re2 boost abseil-cpp microsoft-gsl flatbuffers eigen
    nlohmann_json
  ];

  # FETCHCONTENT needs network access
  __noChroot = true;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DPython_EXECUTABLE=${python3}/bin/python3"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=OFF"
    "-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS"
    "-Donnxruntime_BUILD_UNIT_TESTS=OFF"
    "-Donnxruntime_BUILD_BENCHMARKS=OFF"
    "-Donnxruntime_BUILD_CSHARP=OFF"
    "-Donnxruntime_USE_OPENMP=OFF"
    "-Donnxruntime_USE_TVM=OFF"
    "-Donnxruntime_USE_LLVM=OFF"
    "-Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF"
    "-Donnxruntime_USE_NUPHAR=OFF"
    "-Donnxruntime_USE_TENSORRT=OFF"
    "-Donnxruntime_USE_ROCM=OFF"
    "-Donnxruntime_USE_CUDA=OFF"
    "-Donnxruntime_BUILD_SHARED_LIB=ON"
    "-DProtobuf_USE_STATIC_LIBS=ON"
    "-DCMAKE_IGNORE_PATH=/opt/homebrew/include"
  ];

  meta = with lib; {
    description = "Cross-platform ML inference and training accelerator";
    homepage = "https://github.com/microsoft/onnxruntime";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
