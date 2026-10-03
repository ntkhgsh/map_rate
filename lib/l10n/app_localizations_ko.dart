// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => '지도 중심의 통화';

  @override
  String get resolving => '조회 중…';

  @override
  String get moveMapHint => '지도를 움직이면 중심의 국가와 통화를 감지합니다.';

  @override
  String countryCodeLabel(String code) {
    return '국가 코드 $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return '통화 $label';
  }

  @override
  String get unknown => '알 수 없음';

  @override
  String get invalidCoordinates => '위도 또는 경도가 올바르지 않습니다';

  @override
  String get geocoderUnavailable => '이 기기에서는 국가 조회를 할 수 없습니다';

  @override
  String get countryNotFound => '이 위치의 국가를 확인할 수 없습니다';

  @override
  String get countryLookupFailed => '국가 정보를 가져올 수 없습니다. 연결을 확인하세요.';

  @override
  String get exchangeListTitle => '지도상 환율';

  @override
  String updatedAt(String time) {
    return '업데이트: $time';
  }

  @override
  String rateDate(String date) {
    return '환율 날짜: $date';
  }

  @override
  String get notUpdatedYet => '아직 업데이트되지 않음';

  @override
  String get dataSourceTitle => '환율 데이터 정보';

  @override
  String get dataSourceBody =>
      'MapRate는 ExchangeRate-API(open.er-api.com), CDN 통화 피드, Frankfurter 순으로 중간 환율을 불러옵니다. 금액은 USD를 거쳐 환산합니다. 스파크라인은 Frankfurter 기록이 있을 때 표시합니다. 참고용이며 거래 호가가 아닙니다.';

  @override
  String get pinCountry => '고정';

  @override
  String get unpinCountry => '고정 해제';

  @override
  String get reorderHint => '핸들을 드래그하여 순서 변경';

  @override
  String get loadingRates => '환율 불러오는 중…';

  @override
  String get ratesLoadFailed => '실시간 환율을 불러오지 못했습니다. 내장 시드 표시 중.';

  @override
  String get retry => '다시 시도';

  @override
  String get offlineSeedHint => '오프라인 시드 환율';

  @override
  String get rateUnavailable => '해당 없음';

  @override
  String get noCountriesOnMap => '보이는 통화가 없습니다. 지도를 이동하거나 국가를 고정하세요.';

  @override
  String get amountHint => '금액';

  @override
  String get close => '닫기';

  @override
  String get aboutTitle => 'MapRate 정보';

  @override
  String get aboutBody =>
      'MapRate는 세계 지도와 실시간 환율을 연결합니다. 지도를 움직여 중심 국가의 통화를 보고, 금액을 환산하고, 국가를 고정해 비교하세요.';

  @override
  String get settingsTitle => '설정';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get showTrendChart => '추세 차트 표시';

  @override
  String get trendChartTitle => '환율 추세';

  @override
  String get myLocationTooltip => '내 위치로 이동';

  @override
  String get locationPermissionDenied => '위치 권한이 거부되었습니다';

  @override
  String get locationServiceDisabled => '이 기능을 사용하려면 위치 서비스를 켜세요';

  @override
  String get locationFailed => '위치를 가져올 수 없습니다';

  @override
  String get menuAbout => '정보';

  @override
  String get menuSettings => '설정';

  @override
  String get adLoading => '광고 로드 중…';

  @override
  String get trendAxisUnit => '날짜(일)';

  @override
  String trendYAxisUnit(String currency) {
    return 'USD 1당 $currency';
  }

  @override
  String get baseInputLabel => '입력됨';

  @override
  String get updateAvailableTitle => '업데이트 있음';

  @override
  String updateAvailableBody(String version) {
    return '버전 $version이(가) 있습니다. 업데이트해 주세요.';
  }

  @override
  String get updateNow => '업데이트';

  @override
  String get updateLater => '나중에';

  @override
  String get updateOpenFailed => '스토어를 열 수 없습니다';

  @override
  String appVersionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get checkForUpdate => '업데이트 확인';

  @override
  String get updateUpToDate => '최신 버전입니다';

  @override
  String get updateCheckFailed => '업데이트를 확인할 수 없습니다';

  @override
  String get hideExchangeList => '환율 목록 숨기기';

  @override
  String get showExchangeList => '환율 목록 보기';
}
