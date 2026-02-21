# CLAUDE.md — alidist (personal fork)

## What is this repository?

alibuild/alidist is the **build recipe collection** for the ALICE experiment at CERN LHC.
Each `.sh` file is a package recipe consumed by [aliBuild](https://github.com/alisw/alibuild).

This fork adds a **Nix-based build layer** (`flake.nix` + `nix/`) that runs alongside
the existing alibuild recipes without modifying them.

## Directory structure

```
.
├── *.sh                  # alibuild recipes (READ-ONLY — do not modify)
├── defaults-*.sh         # alibuild build-flag presets
├── CLAUDE.md             # this file
├── flake.nix             # Nix flake entry point
├── nix/
│   ├── overlay.nix       # ALICE overlay for nixpkgs
│   ├── defaults.nix      # Build flags extracted from defaults-o2.sh
│   └── hep/
│       └── root.nix      # ROOT with ALICE-specific CMake flags
└── docs/
    ├── specification.md  # Full Nix-ification specification (Phase 1-3)
    ├── implementation.md # Implementation decisions and notes
    └── user-guide.md     # End-user guide (alibuild → Nix migration)
```

## Development rules

1. **Never modify existing `.sh` files.** The Nix layer is additive only.
2. **Extract, don't duplicate.** Read build flags from `.sh` files as the source of truth;
   the Nix files should document where each flag comes from.
3. **Layer by layer.** Follow the phase plan in `docs/specification.md`.
4. **Test before committing.** Run the verification checklist below.

## Verification checklist

Run these checks in order before committing any changes to Nix files.

```bash
# 1. Syntax and type check (seconds)
nix flake check
#    Expected: "all checks passed!"

# 2. Confirm published outputs (seconds)
nix flake show
#    Expected: overlays.default, packages.*.root, devShells.*.default

# 3. Verify ALICE CMake flags are correctly merged (seconds)
nix eval .#packages.x86_64-linux.root.cmakeFlags
#    Expected: nixpkgs flags followed by ALICE-specific flags
#    (alien=OFF, roofit=ON, pythia8=ON, tmva-sofie=ON, etc.)

# 4. Full ROOT build (tens of minutes; run in CI or background)
nix build .#root
#    Expected: build succeeds, /nix/store/...-root-<version> is produced
#    Check log tail "Enabled support for:" includes:
#      arrow, fftw3, mathmore, pyroot, pythia8, roofit, root7,
#      tmva-sofie, unfold, xrootd

# 5. Dev shell works (after ROOT build)
nix develop
#    Expected: root, cmake, ninja commands are available
```

## Key commands

```bash
nix flake check           # Validate flake structure
nix flake show            # List published outputs
nix build .#root          # Build ALICE-configured ROOT
nix develop               # Enter dev shell (ROOT + cmake + ninja)
```

## Reference files (read-only)

| File | Purpose |
|------|---------|
| `defaults-o2.sh` | Build flags: C++ standard, optimization, VMC toggle |
| `root.sh` | ROOT CMake flags for ALICE |
| `o2.sh` | O2 framework dependencies |
| `o2physics.sh` | O2Physics dependencies (final target) |
