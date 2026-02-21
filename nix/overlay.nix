# ALICE overlay for nixpkgs
final: prev: {
  alice = {
    root = final.callPackage ./hep/root.nix {
      inherit (prev) root arrow-cpp protobuf mold;
      pythia = prev.pythia or null;
    };
  };
}
