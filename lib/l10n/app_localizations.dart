import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MapRate'**
  String get appTitle;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap'**
  String get mapAttribution;

  /// No description provided for @centerCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency at map center'**
  String get centerCurrencyTitle;

  /// No description provided for @resolving.
  ///
  /// In en, this message translates to:
  /// **'Looking up…'**
  String get resolving;

  /// No description provided for @moveMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to detect the country and currency at the center.'**
  String get moveMapHint;

  /// No description provided for @countryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Country code {code}'**
  String countryCodeLabel(String code);

  /// No description provided for @countryWithCode.
  ///
  /// In en, this message translates to:
  /// **'{name} ({code})'**
  String countryWithCode(String name, String code);

  /// No description provided for @currencyLine.
  ///
  /// In en, this message translates to:
  /// **'Currency {label}'**
  String currencyLine(String label);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @invalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Latitude or longitude is invalid'**
  String get invalidCoordinates;

  /// No description provided for @geocoderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device cannot look up countries'**
  String get geocoderUnavailable;

  /// No description provided for @countryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the country at this location'**
  String get countryNotFound;

  /// No description provided for @countryLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch country info. Check your connection.'**
  String get countryLookupFailed;

  /// No description provided for @exchangeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates on map'**
  String get exchangeListTitle;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated: {time}'**
  String updatedAt(String time);

  /// No description provided for @rateDate.
  ///
  /// In en, this message translates to:
  /// **'Rate date: {date}'**
  String rateDate(String date);

  /// No description provided for @notUpdatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not updated yet'**
  String get notUpdatedYet;

  /// No description provided for @dataSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'About exchange data'**
  String get dataSourceTitle;

  /// No description provided for @dataSourceBody.
  ///
  /// In en, this message translates to:
  /// **'MapRate loads mid-market rates from ExchangeRate-API (open.er-api.com), then a CDN currency feed, then Frankfurter. Amounts convert via USD. Sparklines use Frankfurter history when available. Offline, MapRate uses the last saved rates or bundled seed rates, and map tiles you have already viewed. Rates are indicative, not trade quotes.'**
  String get dataSourceBody;

  /// No description provided for @pinCountry.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pinCountry;

  /// No description provided for @unpinCountry.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinCountry;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to reorder'**
  String get reorderHint;

  /// No description provided for @loadingRates.
  ///
  /// In en, this message translates to:
  /// **'Loading rates…'**
  String get loadingRates;

  /// No description provided for @ratesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load live rates. Using saved or bundled rates.'**
  String get ratesLoadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offlineSeedHint.
  ///
  /// In en, this message translates to:
  /// **'Offline / bundled rates'**
  String get offlineSeedHint;

  /// No description provided for @rateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get rateUnavailable;

  /// No description provided for @noCountriesOnMap.
  ///
  /// In en, this message translates to:
  /// **'No currencies in view. Pan the map or pin a country.'**
  String get noCountriesOnMap;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About MapRate'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'MapRate links a world map to exchange rates. Move the map to see each country’s currency at the center, convert amounts, and pin countries to compare. It also works offline with saved or bundled rates.'**
  String get aboutBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @showTrendChart.
  ///
  /// In en, this message translates to:
  /// **'Show trend chart'**
  String get showTrendChart;

  /// No description provided for @trendChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate trend'**
  String get trendChartTitle;

  /// No description provided for @myLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go to my location'**
  String get myLocationTooltip;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to use this feature'**
  String get locationServiceDisabled;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location'**
  String get locationFailed;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading ad…'**
  String get adLoading;

  /// No description provided for @trendAxisUnit.
  ///
  /// In en, this message translates to:
  /// **'Date (day)'**
  String get trendAxisUnit;

  /// No description provided for @trendYAxisUnit.
  ///
  /// In en, this message translates to:
  /// **'{currency} per 1 USD'**
  String trendYAxisUnit(String currency);

  /// No description provided for @baseInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get baseInputLabel;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available. Please update.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the store'**
  String get updateOpenFailed;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersionLabel(String version);

  /// No description provided for @checkForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdate;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get updateUpToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get updateCheckFailed;

  /// No description provided for @hideExchangeList.
  ///
  /// In en, this message translates to:
  /// **'Hide rates'**
  String get hideExchangeList;

  /// No description provided for @showExchangeList.
  ///
  /// In en, this message translates to:
  /// **'Show rates'**
  String get showExchangeList;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
