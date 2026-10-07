# MapRate 1.2.9 — Release notes

## 日本語（Google Play 向け・短文）

起動を速くし、広告の読み込み失敗時の表示も改善しました。

### 詳細
- AdMob の初期化を画面表示後に行い、起動待ちを短縮
- 広告が読めないときに「読み込み中」が残り続けないよう修正
- フォアグラウンド位置サービス権限は引き続き含みません

---

## English (Google Play — short)

Faster startup, plus clearer behavior when a banner ad fails to load.

### Details
- Initialize AdMob after the UI appears to shorten cold start
- Stop leaving a permanent “Loading ad…” message after failed retries
- Still omits foreground location service permission
