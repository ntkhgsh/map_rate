# Changelog

## 1.2.6 (2026-10-07)

### 日本語
- クローズドテスト提出用の versionCode 更新（フォアグラウンド位置権限なし）

### English
- Bump versionCode for closed testing submission (no foreground location permission)

## 1.2.5 (2026-10-07)

### 日本語
- versionCode を 9 に更新（Play で 8 が使用済みのため）

### English
- Bump versionCode to 9 (code 8 already used on Play)

## 1.2.4 (2026-10-07)

### 日本語
- 内部テストの古いビルドを上書きするための versionCode 更新（フォアグラウンド位置権限なし）

### English
- Bump versionCode to overwrite the internal testing track (no foreground location permission)

## 1.2.3 (2026-10-07)

### 日本語
- versionCode を 7 に更新（Play で既に使われている 6 との衝突を回避）
- フォアグラウンド位置サービス権限を含まないビルドを再提出

### English
- Bump versionCode to 7 (avoids conflict with already-used code 6 on Play)
- Resubmit a build without foreground location service permissions

## 1.2.2 (2026-10-06)

### 日本語
- フォアグラウンドサービス関連の権限・サービス定義を追加で除去（Play 申告エラー対応）

### English
- Further removed foreground-service permissions and service declarations (Play Console)

## 1.2.1 (2026-10-06)

### 日本語
- 使っていない `FOREGROUND_SERVICE_LOCATION` 権限を削除（現在地はアプリ操作中の一回取得のみ）

### English
- Removed unused `FOREGROUND_SERVICE_LOCATION` permission (location is a one-shot, in-app request only)

## 1.2.0 (2026-10-06)

### 日本語
- オフラインでも為替表示・国判定・地図タイル（閲覧済み範囲）を使いやすく改善
- 中国など大きな国の沿岸で、一覧から通貨が消える不具合を修正
- アプリに Sora / Noto Sans JP フォントを同梱（オフラインでも同じ見た目）
- アプリアイコンと Play 用グラフィックを刷新
- 大きな画面で広告と現在地ボタンが重ならないよう配置を調整
- 大きな画面では幅に合わせた大きいアダプティブバナーを表示

### English
- Improved offline use for rates, country detection, and map tiles (previously viewed areas)
- Fixed currencies disappearing from the list near coasts of large countries (e.g. China)
- Bundled Sora and Noto Sans JP fonts for consistent offline typography
- Refreshed the app icon and Play Store graphics
- Prevented the banner ad and my-location button from overlapping on large screens
- Show larger width-adaptive banner ads on large screens
