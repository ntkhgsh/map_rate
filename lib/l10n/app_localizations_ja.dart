// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => '中心地点の通貨';

  @override
  String get resolving => '判定中です';

  @override
  String get moveMapHint => '地図を動かすと、中心の国と通貨を判定します';

  @override
  String countryCodeLabel(String code) {
    return '国コード $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name（$code）';
  }

  @override
  String currencyLine(String label) {
    return '通貨 $label';
  }

  @override
  String get unknown => '不明';

  @override
  String get invalidCoordinates => '緯度または経度が不正です';

  @override
  String get geocoderUnavailable => 'この端末では国の判定ができません';

  @override
  String get countryNotFound => 'この地点の国を特定できませんでした';

  @override
  String get countryLookupFailed => '国情報を取得できませんでした。通信状況を確認してください';

  @override
  String get exchangeListTitle => '表示中の為替';

  @override
  String updatedAt(String time) {
    return '更新: $time';
  }

  @override
  String rateDate(String date) {
    return 'レート日付: $date';
  }

  @override
  String get notUpdatedYet => '未更新';

  @override
  String get dataSourceTitle => '為替データの出典';

  @override
  String get dataSourceBody =>
      'MapRate は open.er-api.com、CDN の currency-api、Frankfurter の順で中値レートを取得します。金額は米ドル（USD）経由で換算します。推移グラフは Frankfurter の履歴がある通貨だけ出します。オフライン時は、前回保存したレートまたは同梱の仮レートと、一度見た地図タイルを使います。売買の約定レートではありません。';

  @override
  String get pinCountry => '固定';

  @override
  String get unpinCountry => '固定解除';

  @override
  String get reorderHint => '右端をドラッグして順番を入れ替えられます';

  @override
  String get loadingRates => 'レート取得中…';

  @override
  String get ratesLoadFailed => 'オンライン取得に失敗。保存済みまたは同梱レートを表示中';

  @override
  String get retry => '再取得';

  @override
  String get offlineSeedHint => 'オフライン／同梱レート';

  @override
  String get rateUnavailable => '—';

  @override
  String get noCountriesOnMap => '表示範囲に通貨が分かる国がありません。地図を動かすか、国を固定してください。';

  @override
  String get amountHint => '金額';

  @override
  String get close => '閉じる';

  @override
  String get aboutTitle => 'MapRate について';

  @override
  String get aboutBody =>
      'MapRate は地図と為替レートを結びつけます。地図を動かすと中心の国の通貨を表示し、金額換算や国の固定で比較できます。保存済みまたは同梱レートで、オフラインでも使えます。';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => '端末の設定に従う';

  @override
  String get showTrendChart => '推移グラフを表示';

  @override
  String get trendChartTitle => 'レート推移';

  @override
  String get myLocationTooltip => '現在地へ移動';

  @override
  String get locationPermissionDenied => '位置情報の許可がありません';

  @override
  String get locationServiceDisabled => '位置情報サービスをオンにしてください';

  @override
  String get locationFailed => '現在地を取得できませんでした';

  @override
  String get menuAbout => 'このアプリについて';

  @override
  String get menuSettings => '設定';

  @override
  String get adLoading => '広告を読み込み中…';

  @override
  String get trendAxisUnit => '日付（日）';

  @override
  String trendYAxisUnit(String currency) {
    return '1 USDあたりの$currency';
  }

  @override
  String get baseInputLabel => '入力中';

  @override
  String get updateAvailableTitle => 'アップデートがあります';

  @override
  String updateAvailableBody(String version) {
    return 'バージョン $version が公開されています。更新してください。';
  }

  @override
  String get updateNow => '更新する';

  @override
  String get updateLater => 'あとで';

  @override
  String get updateOpenFailed => 'ストアを開けませんでした';

  @override
  String appVersionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get checkForUpdate => 'アップデートを確認';

  @override
  String get updateUpToDate => '最新バージョンです';

  @override
  String get updateCheckFailed => 'アップデートを確認できませんでした';

  @override
  String get hideExchangeList => '為替リストを隠す';

  @override
  String get showExchangeList => '為替リストを表示';
}
