# Changelog

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
