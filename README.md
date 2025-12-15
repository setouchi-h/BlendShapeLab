# BlendShapeLab

USDZ / USD 内の blendshape（morph target）を、スライダーで動かして見た目の変化を確認するための macOS 用ツールです。

## 使い方

1. `BlendShapeLab/BlendShapeLab.xcodeproj` を Xcode で開く
2. `BlendShapeLab` ターゲットを macOS で Run
3. 以下どちらかでモデルを読み込み
   - `⌘O`（Open…）
   - USDZ/USD ファイルをウィンドウにドラッグ&ドロップ
4. 左の一覧から blendshape 名を選択し、右上のスライダーで 0〜1 を調整

## 操作

- `Solo`: ON の場合、選択中の blendshape 以外の重みを 0 にして単体で確認します
- `Reset All`: 全 blendshape の重みを 0 に戻します
- `Sweep`: 選択中の blendshape を 0↔1 で自動的に往復させます（変化が分かりやすい）

## 対応ファイル

- `.usdz`, `.usd`, `.usda`, `.usdc`

## メモ

- モデルによっては blendshape 名が取得できず、`target_0` のような表示になる場合があります。
  その場合は USDZ 側に name 情報が入っていない/失われている可能性があります。
