# Build flags extracted from defaults-o2.sh
# Source of truth: defaults-o2.sh lines 4-9
{
  cmakeBuildType = "RelWithDebInfo";
  cxxStandard = "20";
  cflags = "-fPIC -O2";
  cxxflags = "-fPIC -O2";
  enableVMC = true;
  geant4Multithreaded = false;
}
