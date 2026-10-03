// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Währung in der Kartenmitte';

  @override
  String get resolving => 'Suche…';

  @override
  String get moveMapHint =>
      'Bewegen Sie die Karte, um Land und Währung in der Mitte zu erkennen.';

  @override
  String countryCodeLabel(String code) {
    return 'Ländercode $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Währung $label';
  }

  @override
  String get unknown => 'Unbekannt';

  @override
  String get invalidCoordinates => 'Breiten- oder Längengrad ungültig';

  @override
  String get geocoderUnavailable => 'Dieses Gerät kann keine Länder ermitteln';

  @override
  String get countryNotFound =>
      'Land an diesem Ort konnte nicht ermittelt werden';

  @override
  String get countryLookupFailed =>
      'Länderinfo konnte nicht geladen werden. Verbindung prüfen.';

  @override
  String get exchangeListTitle => 'Wechselkurse auf der Karte';

  @override
  String updatedAt(String time) {
    return 'Aktualisiert: $time';
  }

  @override
  String rateDate(String date) {
    return 'Kursdatum: $date';
  }

  @override
  String get notUpdatedYet => 'Noch nicht aktualisiert';

  @override
  String get dataSourceTitle => 'Zu den Kursdaten';

  @override
  String get dataSourceBody =>
      'MapRate lädt Mittelkurse von ExchangeRate-API (open.er-api.com), dann einem CDN-Feed und Frankfurter. Beträge werden über USD umgerechnet. Sparklines nutzen Frankfurter-Historie, wenn verfügbar. Kurse sind indikativ, keine Handelskurse.';

  @override
  String get pinCountry => 'Anheften';

  @override
  String get unpinCountry => 'Loslösen';

  @override
  String get reorderHint => 'Griff ziehen zum Sortieren';

  @override
  String get loadingRates => 'Kurse werden geladen…';

  @override
  String get ratesLoadFailed =>
      'Live-Kurse nicht geladen. Gebündelte Seed-Daten werden angezeigt.';

  @override
  String get retry => 'Erneut';

  @override
  String get offlineSeedHint => 'Offline-Seed-Kurse';

  @override
  String get rateUnavailable => 'k. A.';

  @override
  String get noCountriesOnMap =>
      'Keine Währungen sichtbar. Karte schieben oder Land anheften.';

  @override
  String get amountHint => 'Betrag';

  @override
  String get close => 'Schließen';

  @override
  String get aboutTitle => 'Über MapRate';

  @override
  String get aboutBody =>
      'MapRate verbindet eine Weltkarte mit Live-Wechselkursen. Bewegen Sie die Karte, um die Währung in der Mitte zu sehen, Beträge umzurechnen und Länder zum Vergleich anzuheften.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get showTrendChart => 'Trenddiagramm anzeigen';

  @override
  String get trendChartTitle => 'Kursverlauf';

  @override
  String get myLocationTooltip => 'Zu meinem Standort';

  @override
  String get locationPermissionDenied => 'Standortberechtigung verweigert';

  @override
  String get locationServiceDisabled =>
      'Standortdienste einschalten, um diese Funktion zu nutzen';

  @override
  String get locationFailed => 'Standort konnte nicht ermittelt werden';

  @override
  String get menuAbout => 'Über';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get adLoading => 'Anzeige wird geladen…';

  @override
  String get trendAxisUnit => 'Datum (Tag)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency je 1 USD';
  }

  @override
  String get baseInputLabel => 'Eingabe';

  @override
  String get updateAvailableTitle => 'Update verfügbar';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version ist verfügbar. Bitte aktualisieren.';
  }

  @override
  String get updateNow => 'Aktualisieren';

  @override
  String get updateLater => 'Später';

  @override
  String get updateOpenFailed => 'Store konnte nicht geöffnet werden';

  @override
  String appVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdate => 'Nach Updates suchen';

  @override
  String get updateUpToDate => 'Sie nutzen die neueste Version';

  @override
  String get updateCheckFailed => 'Update-Prüfung fehlgeschlagen';

  @override
  String get hideExchangeList => 'Kurse ausblenden';

  @override
  String get showExchangeList => 'Kurse anzeigen';
}
