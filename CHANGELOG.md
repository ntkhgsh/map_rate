# Changelog

## 1.1.0+2

### 日本語

- 広告ブロック検知・入力ロック機能を削除し、バナー広告の読み込みを簡素化
- 大画面向けにラージ・アダプティブバナーを採用
- 為替入力時の bottom overflow を修正（キーボード表示中は FAB／広告を非表示）
- 金額表示・入力で、実質整数のときは小数点を出さないよう改善
- 上部タイトルバーを廃止し、為替パネル見出しにアイコン・アプリ名・バージョンを集約
- アプリアイコン／スプラッシュを更新（交換マークにコーラルのアクセント）
- 起動スプラッシュを青背景＋アイコン表示に整備
- 現在地ボタン押下時のズームを 5 に調整
- レート推移画面をシンプル化（最新値・変化率・塗りグラフ）
- 未対応言語時のフォールバックを英語に統一（Play デフォルト言語と整合）

### English

- Removed ad-block detection / input locking; simplified banner ad loading
- Adopted large anchored adaptive banners for wider screens
- Fixed bottom overflow during FX amount input (hide FAB/ads while keyboard is open)
- Show whole numbers without decimals when the amount is effectively an integer
- Removed the top brand bar; icon, app name, and version now live in the FX panel header
- Updated app icon / splash (coral accent on the exchange mark)
- Polished launch splash with blue background and centered icon
- Set my-location zoom level to 5
- Redesigned the rate trend sheet for clarity (latest value, change %, filled chart)
- Fallback locale is English when the device language is unsupported
