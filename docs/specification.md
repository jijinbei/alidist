# ALICE ソフトウェアスタック Nix 化 — 仕様書

## 1. 背景と動機

### 1.1 alibuild の現状

ALICE 実験のソフトウェアスタック (O2, O2Physics, AliRoot 等) は
[aliBuild](https://github.com/alisw/alibuild) + alidist レシピでビルドされる。

**課題:**
- **再現性の不完全さ**: ホスト環境の差異（glibc バージョン、システムライブラリ）で
  ビルド結果が変わる。`prefer_system` によるシステムライブラリ流用が非決定的。
- **セットアップの重さ**: 初回ビルドに数時間、ディスク数十 GB。
  バイナリキャッシュ (CVMFS) はあるがローカル開発では恩恵が薄い。
- **属人性**: レシピは bash スクリプトで、依存解決・パッチ適用の暗黙知が多い。

### 1.2 Nix 化の利点

- **完全な再現性**: Nix store によるハッシュベースの依存管理。
  同一入力 → 同一出力を保証。
- **宣言的な構成**: `.sh` スクリプトの暗黙知を Nix 式として明示化。
- **バイナリキャッシュ**: Nix のキャッシュ機構により、変更のないパッケージは
  再ビルド不要。`cachix` 等で CI キャッシュも容易。
- **開発環境の統一**: `nix develop` で全開発者が同一環境を即時取得。

## 2. 依存パッケージの分類

### 2.1 nixpkgs にそのまま使えるもの (Layer 0)

| パッケージ | nixpkgs attr | 備考 |
|-----------|-------------|------|
| CMake | `cmake` | |
| Ninja | `ninja` | |
| GSL | `gsl` | |
| OpenSSL | `openssl` | |
| FreeType | `freetype` | |
| libpng | `libpng` | |
| lzma/xz | `xz` | |
| libxml2 | `libxml2` | |
| FFTW3 | `fftw` | |
| TBB | `tbb` | nixpkgs では `onetbb` |
| protobuf | `protobuf` | |
| nlohmann_json | `nlohmann_json` | |
| Python 3 | `python3` | |
| zlib | `zlib` | |
| Arrow | `arrow-cpp` | |
| fmt | `fmt` | |
| boost | `boost` | |
| curl | `curl` | |
| zeromq | `zeromq` | |
| libuv | `libuv` | |
| GMP | `gmp` | |
| MPFR | `mpfr` | |

### 2.2 nixpkgs を override して使うもの (Layer 1)

| パッケージ | 理由 |
|-----------|------|
| ROOT | ALICE 固有の CMake フラグ、alisw fork の場合はソースも変更 |
| XRootD | バージョン固定が必要な場合 |
| Pythia8 | HEP 固有、nixpkgs にあるが設定調整が必要 |

### 2.3 自前ビルドが必要なもの (Layer 2-3)

| パッケージ | 理由 |
|-----------|------|
| FairRoot | ALICE/FAIR 固有のフレームワーク |
| FairMQ | FairRoot のメッセージングレイヤー |
| Vc | SIMD ライブラリ、nixpkgs にない |
| GEANT3/4_VMC | VMC インターフェース |
| AliEn-Runtime | Grid middleware |
| O2 | ALICE O2 フレームワーク本体 |
| O2Physics | 物理解析フレームワーク |

## 3. フェーズ計画

### Phase 1: 基盤 (Layer 0-1) ← **今回のスコープ**

- nixpkgs パッケージの確認・動作検証
- ROOT の ALICE override
- 最小限の `devShell`
- `nix flake check` / `nix build .#root` が通ること

### Phase 2: HEP スタック (Layer 2)

- FairRoot, Vc, Pythia, GEANT 系のパッケージング
- `nix/hep/` 以下に各パッケージの derivation を追加
- `nix build .#fairroot` 等が通ること

### Phase 3: ALICE アプリケーション (Layer 3)

- O2, O2Physics のパッケージング
- 開発用 `devShell` の充実
- CI 統合 (GitHub Actions + Nix cache)
- `nix build .#o2physics` が通ること

## 4. リポジトリ構成 (最終形)

```
alidist/
├── *.sh                      # 既存レシピ (変更なし)
├── flake.nix                 # エントリポイント
├── flake.lock                # 依存ロック
├── nix/
│   ├── overlay.nix           # ALICE overlay
│   ├── defaults.nix          # ビルドフラグ定義
│   └── hep/
│       ├── root.nix          # ROOT override
│       ├── fairroot.nix      # FairRoot (Phase 2)
│       ├── pythia.nix        # Pythia (Phase 2)
│       ├── geant.nix         # GEANT VMC (Phase 2)
│       ├── o2.nix            # O2 (Phase 3)
│       └── o2physics.nix     # O2Physics (Phase 3)
└── docs/
    ├── specification.md      # この文書
    └── implementation.md     # 実装メモ
```
