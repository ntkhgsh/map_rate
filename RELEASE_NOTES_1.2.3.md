# MapRate 1.2.3 — Release notes

## 日本語（Google Play 向け・短文）

Play 提出用のビルド番号を更新しました。フォアグラウンド位置サービス権限は引き続き含みません。

### 詳細
- versionCode を 7 に更新（既存の 6 との衝突を回避）
- 現在地はアプリ操作中の一回取得のみ（画面オフでの継続測位なし）
- ライブラリ由来の `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_LOCATION` はマニフェストから除去済み

---

## English (Google Play — short)

Build number updated for Play upload. This release still does not include foreground location service permissions.

### Details
- versionCode set to 7 (avoids conflict with existing code 6)
- Location is a one-shot, in-app request only (no background tracking)
- Library-merged `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_LOCATION` remain removed from the manifest
