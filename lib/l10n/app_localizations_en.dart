// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Currency at map center';

  @override
  String get resolving => 'Looking up…';

  @override
  String get moveMapHint =>
      'Move the map to detect the country and currency at the center.';

  @override
  String countryCodeLabel(String code) {
    return 'Country code $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Currency $label';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get invalidCoordinates => 'Latitude or longitude is invalid';

  @override
  String get geocoderUnavailable => 'This device cannot look up countries';

  @override
  String get countryNotFound =>
      'Could not identify the country at this location';

  @override
  String get countryLookupFailed =>
      'Could not fetch country info. Check your connection.';

  @override
  String get exchangeListTitle => 'Exchange rates on map';

  @override
  String updatedAt(String time) {
    return 'Updated: $time';
  }

  @override
  String rateDate(String date) {
    return 'Rate date: $date';
  }

  @override
  String get notUpdatedYet => 'Not updated yet';

  @override
  String get dataSourceTitle => 'About exchange data';

  @override
  String get dataSourceBody =>
      'MapRate loads mid-market rates from ExchangeRate-API (open.er-api.com), then a CDN currency feed, then Frankfurter. Amounts convert via USD. Sparklines use Frankfurter history when available. Rates are indicative, not trade quotes.';

  @override
  String get pinCountry => 'Pin';

  @override
  String get unpinCountry => 'Unpin';

  @override
  String get reorderHint => 'Drag the handle to reorder';

  @override
  String get loadingRates => 'Loading rates…';

  @override
  String get ratesLoadFailed =>
      'Could not load live rates. Showing bundled seed.';

  @override
  String get retry => 'Retry';

  @override
  String get offlineSeedHint => 'Offline seed rates';

  @override
  String get rateUnavailable => 'N/A';

  @override
  String get noCountriesOnMap =>
      'No currencies in view. Pan the map or pin a country.';

  @override
  String get amountHint => 'Amount';

  @override
  String get close => 'Close';

  @override
  String get aboutTitle => 'About MapRate';

  @override
  String get aboutBody =>
      'MapRate links a world map to live exchange rates. Move the map to see each country’s currency at the center, convert amounts, and pin countries to compare.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get showTrendChart => 'Show trend chart';

  @override
  String get trendChartTitle => 'Rate trend';

  @override
  String get myLocationTooltip => 'Go to my location';

  @override
  String get locationPermissionDenied => 'Location permission was denied';

  @override
  String get locationServiceDisabled =>
      'Turn on location services to use this feature';

  @override
  String get locationFailed => 'Could not get your location';

  @override
  String get menuAbout => 'About';

  @override
  String get menuSettings => 'Settings';

  @override
  String get adLoading => 'Loading ad…';

  @override
  String get trendAxisUnit => 'Date (day)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency per 1 USD';
  }

  @override
  String get baseInputLabel => 'Entered';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version is available. Please update.';
  }

  @override
  String get updateNow => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String get updateOpenFailed => 'Could not open the store';

  @override
  String appVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdate => 'Check for updates';

  @override
  String get updateUpToDate => 'You are on the latest version';

  @override
  String get updateCheckFailed => 'Could not check for updates';

  @override
  String get hideExchangeList => 'Hide rates';

  @override
  String get showExchangeList => 'Show rates';
}
