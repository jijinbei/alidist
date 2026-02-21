# 実装メモ — Layer 0-1

## 1. nixpkgs の ROOT パッケージ調査

### 現状 (2025-02 時点)

- **nixpkgs attr**: `pkgs.root`
- **バージョン**: 6.38.00
- **定義場所**: `pkgs/by-name/ro/root/package.nix`
- **ライセンス**: LGPL-2.1
- **LLVM**: 外部 LLVM 20 (ROOT パッチ済み Clang, `clang-root.nix`)
- **clad**: v2.0 同梱

### nixpkgs ROOT の CMake フラグ

```nix
cmakeFlags = [
  "-DCLAD_SOURCE_DIR=${finalAttrs.clad_src}"
  "-DClang_DIR=${finalAttrs.clang}/lib/cmake/clang"
  "-Dbuiltin_clang=OFF"
  "-Dbuiltin_llvm=OFF"
  "-Dfail-on-missing=ON"
  "-Dfftw3=ON"
  "-Dfitsio=OFF"
  "-Dmathmore=ON"
  "-Dsqlite=OFF"
  "-Dvdt=OFF"
];
```

### Override 方法

`finalAttrs` パターンで定義されているため:
- `.override { ... }` — 入力（依存）の変更
- `.overrideAttrs (old: { ... })` — derivation 属性の変更（cmakeFlags 等）

## 2. ALICE 固有の ROOT CMake フラグ

`root.sh` (lines 141-200) から抽出。nixpkgs と異なるもの、または追加が必要なものを列挙。

### ALICE が有効にするフラグ (nixpkgs にないもの)

| フラグ | 値 | 出典 |
|-------|-----|------|
| `-Dalien=OFF` | OFF | root.sh:145 |
| `-Dfreetype=ON` | ON | root.sh:147 |
| `-Dbuiltin_freetype=OFF` | OFF | root.sh:148 |
| `-Dpcre=OFF` | OFF | root.sh:149 |
| `-Dbuiltin_pcre=ON` | ON | root.sh:150 |
| `-Dxrootd=ON` | ON | root.sh:123 |
| `-Dpyroot=ON` | ON | root.sh:104 |
| `-Darrow=ON` | ON | root.sh:154 (条件付き) |
| `-Dminuit=ON` | ON | root.sh:177 |
| `-Droofit=ON` | ON | root.sh:179 |
| `-Dhttp=ON` | ON | root.sh:180 |
| `-Droot7=ON` | ON | root.sh:181 |
| `-Dsoversion=ON` | ON | root.sh:182 |
| `-Dshadowpw=OFF` | OFF | root.sh:183 |
| `-Dvc=ON` | ON | root.sh:185 |
| `-Dbuiltin_vc=OFF` | OFF | root.sh:186 |
| `-Dbuiltin_vdt=OFF` | OFF | root.sh:187 |
| `-Dgviz=OFF` | OFF | root.sh:188 |
| `-Dbuiltin_davix=OFF` | OFF | root.sh:189 |
| `-Dbuiltin_fftw3=OFF` | OFF | root.sh:190 |
| `-Dtmva-sofie=ON` | ON | root.sh:191 |
| `-Dtmva-gpu=OFF` | OFF | root.sh:192 |
| `-Ddavix=OFF` | OFF | root.sh:193 |
| `-Dunfold=ON` | ON | root.sh:194 |
| `-Dpythia8=ON` | ON | root.sh:195 |
| `-Dfortran=OFF` | OFF | root.sh:161 |
| `-Dpgsql=OFF` | OFF | root.sh:176 |

### v6.36 固有フラグ

```
-Dpythia6=ON -Dpythia6_nolink=ON -Dproof=ON -Dgeombuilder=ON
```

## 3. defaults-o2.sh からの抽出

```yaml
CFLAGS: -fPIC -O2
CMAKE_BUILD_TYPE: RELWITHDEBINFO
CXXFLAGS: -fPIC -O2 -std=c++20
CXXSTD: '20'
ENABLE_VMC: 'ON'
GEANT4_BUILD_MULTITHREADED: 'OFF'
```

→ `nix/defaults.nix` として Nix attribute set に変換。

## 4. バージョン差異の考慮

- **ALICE**: ROOT v6.36.04 (alisw/root fork, tag `v6-36-04-alice9`)
- **nixpkgs**: ROOT 6.38.00 (upstream root-project)

Phase 1 では nixpkgs の ROOT (6.38) をベースに ALICE フラグを追加する。
alisw fork への切り替え（ソースの差し替え）は必要に応じて後のフェーズで対応。

## 5. 判断ログ

### なぜ nixpkgs ROOT をベースにするか

1. nixpkgs の ROOT は LLVM/Clang 統合が適切に処理されており、
   パッチ済み Clang (`clang-root.nix`) を使用している。これを自前で再現するのは高コスト。
2. ALICE パッチの多くはバックポートや小修正であり、CMake フラグの差異が主要な違い。
3. 6.38 と 6.36 の API 差異は Layer 1 のスコープでは問題にならない
   （ROOT 単体のビルド可否の検証が目的）。

### なぜ Vc をスキップするか (Layer 1)

nixpkgs に Vc パッケージがない。ROOT の `-Dvc=ON` には外部 Vc が必要だが、
nixpkgs ROOT は Vc なしで動作する。Layer 1 では Vc を無効にし、
Layer 2 で Vc の derivation を作成してから有効化する。
