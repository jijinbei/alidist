# O2Physics を Nix で使う — ユーザーガイド

> **ステータス**: このドキュメントは将来像を描いたものです。
> 現在は Layer 0-1 (ROOT override) のみ実装済みです。

## 対象読者

ALICE の物理解析を行う大学院生・研究者。
従来の alibuild セットアップの代わりに Nix で開発環境を構築する方法を説明する。

## あなたに必要なのは？

alibuild の場合、目的に応じて `aliBuild init` するパッケージが異なる:

| 目的 | alibuild | Nix (将来) |
|------|---------|------------|
| **Run 3 解析コード開発** (最も一般的) | `aliBuild init O2Physics@master` | `nix develop .#o2physics` |
| Run 3 コアソフト開発 (まれ) | `aliBuild init O2@dev` | `nix develop .#o2` |
| Run 2 解析コード開発 | `aliBuild init AliPhysics@master` | 対象外 (alibuild を使用) |
| Run 2 コアソフト開発 (まれ) | `aliBuild init AliRoot@master` | 対象外 (alibuild を使用) |

> **Note**: Nix 化の対象は Run 3 スタック (O2, O2Physics) のみ。
> Run 2 (AliRoot, AliPhysics) は引き続き alibuild を使用してください。

ほとんどの解析ユーザーは **O2Physics** だけあれば十分。
以下では O2Physics を Nix で使うケースを中心に説明する。

---

## alibuild との比較

| | alibuild | Nix |
|---|---------|-----|
| **初回セットアップ** | `aliBuild build O2Physics` (数時間、数十 GB) | `nix develop` (バイナリキャッシュから数分) |
| **環境の切り替え** | `alienv enter O2Physics/latest` | `nix develop` または `direnv` で自動 |
| **再現性** | ホスト環境に依存（glibc, system libs） | 完全再現（Nix store でハッシュ固定） |
| **複数バージョン共存** | 困難（CVMFS 上の固定バージョンのみ） | `nix develop .#o2physics-v1` 等で自由に切替 |
| **ディスク使用量** | プロジェクトごとに独立（重複大） | Nix store で共有（重複なし） |
| **OS 要件** | CentOS/Alma/macOS | Nix が動く任意の Linux/macOS |

---

## alibuild と Nix の根本的な違い

alibuild は **「ソース取得 → 全依存をビルド → 環境に入る」** という流れ:

```bash
aliBuild init O2Physics@master          # 1. ソース取得
aliBuild build O2Physics --defaults o2  # 2. 全依存を含めてビルド (数時間, 数十GB)
alienv enter O2Physics/latest           # 3. 環境に入る
```

Nix は **「依存はバイナリキャッシュから取得、開発するものだけ手元でビルド」**:

```bash
git clone https://github.com/AliceO2Group/O2Physics.git  # 1. ソース取得 (普通の git clone)
cd O2Physics
nix develop github:<user>/alidist#o2physics               # 2. 依存環境に入る (キャッシュから数分)
cmake -B build -G Ninja && cmake --build build             # 3. 自分のコードだけビルド
```

`aliBuild init` に直接対応するコマンドはない。
Nix では「ソース取得」(git clone) と「依存環境の構築」(`nix develop`) が分離されている。

### 4つのケースの具体的な手順

**Run 3 解析コード開発 (最も一般的):**
```bash
# alibuild の場合
aliBuild init O2Physics@master
aliBuild build O2Physics --defaults o2   # ROOT, O2, 全依存をソースからビルド
alienv enter O2Physics/latest

# Nix の場合
git clone https://github.com/AliceO2Group/O2Physics.git
cd O2Physics
nix develop github:<user>/alidist#o2physics  # ROOT, O2 等はキャッシュから即取得
cmake -B build -G Ninja
cmake --build build
```

**Run 3 コアソフト開発 (まれ):**
```bash
# alibuild の場合
aliBuild init O2@dev
aliBuild build O2 --defaults o2
alienv enter O2/latest

# Nix の場合
git clone https://github.com/AliceO2Group/AliceO2.git
cd AliceO2
nix develop github:<user>/alidist#o2  # ROOT, FairRoot 等はキャッシュから
cmake -B build -G Ninja
cmake --build build
```

**Run 2 (AliPhysics, AliRoot):**
Nix 化の対象外。従来通り alibuild を使用。

---

## クイックスタート

### 前提条件

Nix がインストールされていること (flake 有効):

```bash
# Nix 未インストールの場合
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
```

### 1. 依存環境に入る

```bash
# O2Physics のソースを取得
git clone https://github.com/AliceO2Group/O2Physics.git
cd O2Physics

# alidist の flake から依存環境を取得
nix develop github:<your-user>/alidist#o2physics
```

これで以下がすべて PATH に入った状態になる:
- ROOT (ALICE 設定済み)
- O2 フレームワーク
- O2Physics ライブラリ
- cmake, ninja 等のビルドツール

### 2. 自分の解析コードをビルド

```bash
# nix develop の中で
cmake -B build -G Ninja
cmake --build build
```

O2Physics のヘッダとライブラリは Nix store から自動的に参照される。
`$O2PHYSICS_ROOT` 等の環境変数も設定済み。

### 3. 特定バージョンを使う

```bash
# flake.lock を特定コミットに固定
nix develop github:<your-user>/alidist/<commit-hash>#o2physics

# または入力を上書き
nix develop --override-input nixpkgs github:NixOS/nixpkgs/<nixpkgs-rev>
```

---

## direnv との連携 (推奨)

プロジェクトディレクトリに `.envrc` を置くと、`cd` するだけで環境が自動ロードされる。

```bash
# 解析プロジェクトのルートで
echo 'use flake /path/to/alidist#o2physics' > .envrc
direnv allow
```

以降は `cd ~/my-analysis` するだけで O2Physics 環境が有効になる。
離れると自動で無効化。

---

## 典型的なワークフロー

### 日常の解析作業

```bash
cd ~/my-analysis        # direnv で自動的に O2Physics 環境が有効化
vim my_task.cxx         # 編集
cmake --build build     # ビルド
o2-analysis-... | ...   # 実行
```

### O2Physics 自体の開発

```bash
# O2Physics ソースを持ってきて開発モードに入る
git clone https://github.com/AliceO2Group/O2Physics.git
cd O2Physics

# alidist の devShell を使うが、O2Physics 自体はソースからビルド
nix develop /path/to/alidist#o2physics-dev

cmake -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$PWD/install
cmake --build build -- install
```

### Grid ジョブとの互換性

Grid (JAliEn) 上では引き続き CVMFS の alibuild バイナリが使われる。
Nix 環境はローカル開発専用。解析コード自体は同じなので互換性の問題はない。

---

## FAQ

### Q: alibuild と Nix は共存できる？

はい。Nix のファイルは `flake.nix` と `nix/` ディレクトリに閉じており、
既存の `.sh` レシピには一切変更を加えません。alibuild は従来通り使えます。

### Q: ビルドにどれくらい時間がかかる？

- **バイナリキャッシュあり**: 数分（ダウンロードのみ）
- **キャッシュなし (初回)**: ROOT のビルドに 30-60 分程度。
  ただし一度ビルドすれば Nix store にキャッシュされ、以降は即座に使える。

### Q: ROOT のバージョンが nixpkgs と ALICE で違うが大丈夫？

Layer 1 では nixpkgs の ROOT (6.38) をベースに ALICE フラグを追加しています。
将来的に alisw/root fork (6.36) が必要になった場合は、
`nix/hep/root.nix` でソースとバージョンを差し替えることで対応します。

### Q: macOS でも使える？

はい。Nix は macOS (Intel/Apple Silicon) をサポートしています。
`flake.nix` は `flake-utils.lib.eachDefaultSystem` で全主要プラットフォームに対応します。

### Q: CVMFS / alibuild 環境との混在は問題ない？

Nix 環境は `nix develop` シェルの中に閉じているため、
CVMFS の `alienv` と干渉しません。ただし同一シェルで両方を有効にすることは避けてください。

### Q: CI で使える？

はい。GitHub Actions で Nix を使う例:

```yaml
- uses: cachix/install-nix-action@v27
- uses: cachix/cachix-action@v15
  with:
    name: your-cache-name
- run: nix build .#o2physics
- run: nix develop .#o2physics -c bash -c "cd tests && ctest"
```

---

## パッケージ構成 (完成時)

```
nix develop .#o2physics      # O2Physics + 全依存 (解析ユーザー向け)
nix develop .#o2physics-dev  # 上記 + ビルドツール (O2Physics 開発者向け)
nix develop .#o2              # O2 のみ (フレームワーク開発者向け)
nix develop .#root            # ROOT のみ (ROOT 開発/テスト用)

nix build .#o2physics         # O2Physics バイナリ
nix build .#root              # ALICE 版 ROOT バイナリ
```
