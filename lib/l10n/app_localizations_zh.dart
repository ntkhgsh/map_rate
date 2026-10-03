// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => '地图中心的货币';

  @override
  String get resolving => '正在查询…';

  @override
  String get moveMapHint => '移动地图以检测中心位置的国家和货币。';

  @override
  String countryCodeLabel(String code) {
    return '国家代码 $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name（$code）';
  }

  @override
  String currencyLine(String label) {
    return '货币 $label';
  }

  @override
  String get unknown => '未知';

  @override
  String get invalidCoordinates => '纬度或经度无效';

  @override
  String get geocoderUnavailable => '此设备无法查询国家';

  @override
  String get countryNotFound => '无法识别此位置的国家';

  @override
  String get countryLookupFailed => '无法获取国家信息。请检查网络连接。';

  @override
  String get exchangeListTitle => '地图上的汇率';

  @override
  String updatedAt(String time) {
    return '更新：$time';
  }

  @override
  String rateDate(String date) {
    return '汇率日期：$date';
  }

  @override
  String get notUpdatedYet => '尚未更新';

  @override
  String get dataSourceTitle => '关于汇率数据';

  @override
  String get dataSourceBody =>
      'MapRate 依次从 ExchangeRate-API（open.er-api.com）、CDN 货币源和 Frankfurter 获取中间价。金额通过美元（USD）换算。走势图在 Frankfurter 有历史数据时显示。仅供参考，非交易报价。';

  @override
  String get pinCountry => '固定';

  @override
  String get unpinCountry => '取消固定';

  @override
  String get reorderHint => '拖动把手以重新排序';

  @override
  String get loadingRates => '正在加载汇率…';

  @override
  String get ratesLoadFailed => '无法加载实时汇率。显示内置种子数据。';

  @override
  String get retry => '重试';

  @override
  String get offlineSeedHint => '离线种子汇率';

  @override
  String get rateUnavailable => '不可用';

  @override
  String get noCountriesOnMap => '视野内没有可识别的货币。请平移地图或固定一个国家。';

  @override
  String get amountHint => '金额';

  @override
  String get close => '关闭';

  @override
  String get aboutTitle => '关于 MapRate';

  @override
  String get aboutBody => 'MapRate 将世界地图与实时汇率相连。移动地图查看中心国家的货币，换算金额并固定国家以便比较。';

  @override
  String get settingsTitle => '设置';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get showTrendChart => '显示走势图表';

  @override
  String get trendChartTitle => '汇率走势';

  @override
  String get myLocationTooltip => '前往我的位置';

  @override
  String get locationPermissionDenied => '位置权限被拒绝';

  @override
  String get locationServiceDisabled => '请开启定位服务以使用此功能';

  @override
  String get locationFailed => '无法获取您的位置';

  @override
  String get menuAbout => '关于';

  @override
  String get menuSettings => '设置';

  @override
  String get adLoading => '正在加载广告…';

  @override
  String get trendAxisUnit => '日期（日）';

  @override
  String trendYAxisUnit(String currency) {
    return '每 1 USD 的 $currency';
  }

  @override
  String get baseInputLabel => '已输入';

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String updateAvailableBody(String version) {
    return '版本 $version 已发布，请更新。';
  }

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后';

  @override
  String get updateOpenFailed => '无法打开商店';

  @override
  String appVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkForUpdate => '检查更新';

  @override
  String get updateUpToDate => '已是最新版本';

  @override
  String get updateCheckFailed => '无法检查更新';

  @override
  String get hideExchangeList => '隐藏汇率列表';

  @override
  String get showExchangeList => '显示汇率列表';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => '地圖中心的貨幣';

  @override
  String get resolving => '正在查詢…';

  @override
  String get moveMapHint => '移動地圖以偵測中心位置的國家與貨幣。';

  @override
  String countryCodeLabel(String code) {
    return '國家代碼 $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name（$code）';
  }

  @override
  String currencyLine(String label) {
    return '貨幣 $label';
  }

  @override
  String get unknown => '未知';

  @override
  String get invalidCoordinates => '緯度或經度無效';

  @override
  String get geocoderUnavailable => '此裝置無法查詢國家';

  @override
  String get countryNotFound => '無法識別此位置的國家';

  @override
  String get countryLookupFailed => '無法取得國家資訊。請檢查網路連線。';

  @override
  String get exchangeListTitle => '地圖上的匯率';

  @override
  String updatedAt(String time) {
    return '更新：$time';
  }

  @override
  String rateDate(String date) {
    return '匯率日期：$date';
  }

  @override
  String get notUpdatedYet => '尚未更新';

  @override
  String get dataSourceTitle => '關於匯率資料';

  @override
  String get dataSourceBody =>
      'MapRate 依序從 ExchangeRate-API（open.er-api.com）、CDN 貨幣來源與 Frankfurter 取得中間價。金額經美元（USD）換算。走勢圖在 Frankfurter 有歷史資料時顯示。僅供參考，非交易報價。';

  @override
  String get pinCountry => '固定';

  @override
  String get unpinCountry => '取消固定';

  @override
  String get reorderHint => '拖曳把手以重新排序';

  @override
  String get loadingRates => '正在載入匯率…';

  @override
  String get ratesLoadFailed => '無法載入即時匯率。顯示內建種子資料。';

  @override
  String get retry => '重試';

  @override
  String get offlineSeedHint => '離線種子匯率';

  @override
  String get rateUnavailable => '不可用';

  @override
  String get noCountriesOnMap => '視野內沒有可識別的貨幣。請平移地圖或固定一個國家。';

  @override
  String get amountHint => '金額';

  @override
  String get close => '關閉';

  @override
  String get aboutTitle => '關於 MapRate';

  @override
  String get aboutBody => 'MapRate 將世界地圖與即時匯率連結。移動地圖查看中心國家的貨幣，換算金額並固定國家以便比較。';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageTitle => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get showTrendChart => '顯示走勢圖表';

  @override
  String get trendChartTitle => '匯率走勢';

  @override
  String get myLocationTooltip => '前往我的位置';

  @override
  String get locationPermissionDenied => '位置權限遭拒';

  @override
  String get locationServiceDisabled => '請開啟定位服務以使用此功能';

  @override
  String get locationFailed => '無法取得您的位置';

  @override
  String get menuAbout => '關於';

  @override
  String get menuSettings => '設定';

  @override
  String get adLoading => '正在載入廣告…';

  @override
  String get trendAxisUnit => '日期（日）';

  @override
  String trendYAxisUnit(String currency) {
    return '每 1 USD 的 $currency';
  }

  @override
  String get baseInputLabel => '已輸入';

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String updateAvailableBody(String version) {
    return '版本 $version 已發布，請更新。';
  }

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍後';

  @override
  String get updateOpenFailed => '無法開啟商店';

  @override
  String appVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkForUpdate => '檢查更新';

  @override
  String get updateUpToDate => '已是最新版本';

  @override
  String get updateCheckFailed => '無法檢查更新';

  @override
  String get hideExchangeList => '隱藏匯率列表';

  @override
  String get showExchangeList => '顯示匯率列表';
}
