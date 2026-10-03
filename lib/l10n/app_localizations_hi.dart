// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'मानचित्र केंद्र की मुद्रा';

  @override
  String get resolving => 'खोज की जा रही है…';

  @override
  String get moveMapHint =>
      'केंद्र पर देश और मुद्रा पहचानने के लिए मानचित्र हिलाएँ।';

  @override
  String countryCodeLabel(String code) {
    return 'देश कोड $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'मुद्रा $label';
  }

  @override
  String get unknown => 'अज्ञात';

  @override
  String get invalidCoordinates => 'अक्षांश या देशांतर अमान्य है';

  @override
  String get geocoderUnavailable => 'यह डिवाइस देश खोज नहीं सकता';

  @override
  String get countryNotFound => 'इस स्थान का देश पहचाना नहीं जा सका';

  @override
  String get countryLookupFailed => 'देश की जानकारी नहीं मिली। कनेक्शन जाँचें।';

  @override
  String get exchangeListTitle => 'मानचित्र पर विनिमय दर';

  @override
  String updatedAt(String time) {
    return 'अपडेट: $time';
  }

  @override
  String rateDate(String date) {
    return 'दर तिथि: $date';
  }

  @override
  String get notUpdatedYet => 'अभी अपडेट नहीं';

  @override
  String get dataSourceTitle => 'विनिमय डेटा के बारे में';

  @override
  String get dataSourceBody =>
      'MapRate ExchangeRate-API (open.er-api.com), CDN मुद्रा फ़ीड, फिर Frankfurter से मध्य-बाज़ार दरें लाता है। राशि USD के माध्यम से परिवर्तित होती है। स्पार्कलाइन Frankfurter इतिहास पर आधारित। दरें संकेतात्मक हैं, ट्रेड कोट नहीं।';

  @override
  String get pinCountry => 'पिन';

  @override
  String get unpinCountry => 'अनपिन';

  @override
  String get reorderHint => 'क्रम बदलने के लिए हैंडल खींचें';

  @override
  String get loadingRates => 'दरें लोड हो रही हैं…';

  @override
  String get ratesLoadFailed =>
      'लाइव दरें लोड नहीं हुईं। बंडल्ड सीड दिखाया जा रहा है।';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get offlineSeedHint => 'ऑफ़लाइन सीड दरें';

  @override
  String get rateUnavailable => 'उपलब्ध नहीं';

  @override
  String get noCountriesOnMap =>
      'दृश्य में कोई मुद्रा नहीं। मानचित्र घुमाएँ या देश पिन करें।';

  @override
  String get amountHint => 'राशि';

  @override
  String get close => 'बंद करें';

  @override
  String get aboutTitle => 'MapRate के बारे में';

  @override
  String get aboutBody =>
      'MapRate विश्व मानचित्र को लाइव विनिमय दरों से जोड़ता है। केंद्र पर देश की मुद्रा देखने, राशि बदलने और तुलना के लिए देश पिन करने हेतु मानचित्र हिलाएँ।';

  @override
  String get settingsTitle => 'सेटिंग';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get showTrendChart => 'ट्रेंड चार्ट दिखाएँ';

  @override
  String get trendChartTitle => 'दर प्रवृत्ति';

  @override
  String get myLocationTooltip => 'मेरे स्थान पर जाएँ';

  @override
  String get locationPermissionDenied => 'स्थान अनुमति अस्वीकृत';

  @override
  String get locationServiceDisabled =>
      'इस सुविधा के लिए स्थान सेवाएँ चालू करें';

  @override
  String get locationFailed => 'आपका स्थान प्राप्त नहीं हो सका';

  @override
  String get menuAbout => 'के बारे में';

  @override
  String get menuSettings => 'सेटिंग';

  @override
  String get adLoading => 'विज्ञापन लोड हो रहा है…';

  @override
  String get trendAxisUnit => 'तिथि (दिन)';

  @override
  String trendYAxisUnit(String currency) {
    return '1 USD पर $currency';
  }

  @override
  String get baseInputLabel => 'दर्ज';

  @override
  String get updateAvailableTitle => 'अपडेट उपलब्ध है';

  @override
  String updateAvailableBody(String version) {
    return 'संस्करण $version उपलब्ध है। कृपया अपडेट करें।';
  }

  @override
  String get updateNow => 'अपडेट';

  @override
  String get updateLater => 'बाद में';

  @override
  String get updateOpenFailed => 'स्टोर नहीं खुल सका';

  @override
  String appVersionLabel(String version) {
    return 'संस्करण $version';
  }

  @override
  String get checkForUpdate => 'अपडेट जांचें';

  @override
  String get updateUpToDate => 'आप नवीनतम संस्करण पर हैं';

  @override
  String get updateCheckFailed => 'अपडेट जाँच नहीं हो सकी';

  @override
  String get hideExchangeList => 'दरें छिपाएँ';

  @override
  String get showExchangeList => 'दरें दिखाएँ';
}
