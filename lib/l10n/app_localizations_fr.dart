// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Devise au centre de la carte';

  @override
  String get resolving => 'Recherche…';

  @override
  String get moveMapHint =>
      'Déplacez la carte pour détecter le pays et la devise au centre.';

  @override
  String countryCodeLabel(String code) {
    return 'Code pays $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Devise $label';
  }

  @override
  String get unknown => 'Inconnu';

  @override
  String get invalidCoordinates => 'Latitude ou longitude invalide';

  @override
  String get geocoderUnavailable =>
      'Cet appareil ne peut pas identifier les pays';

  @override
  String get countryNotFound => 'Impossible d’identifier le pays à cet endroit';

  @override
  String get countryLookupFailed =>
      'Impossible d’obtenir les infos pays. Vérifiez la connexion.';

  @override
  String get exchangeListTitle => 'Taux de change sur la carte';

  @override
  String updatedAt(String time) {
    return 'Mis à jour : $time';
  }

  @override
  String rateDate(String date) {
    return 'Date du taux : $date';
  }

  @override
  String get notUpdatedYet => 'Pas encore mis à jour';

  @override
  String get dataSourceTitle => 'À propos des données de change';

  @override
  String get dataSourceBody =>
      'MapRate charge des taux médians depuis ExchangeRate-API (open.er-api.com), puis un flux CDN et Frankfurter. Les montants passent par l’USD. Les courbes utilisent l’historique Frankfurter si disponible. Taux indicatifs, pas des cotations de trading.';

  @override
  String get pinCountry => 'Épingler';

  @override
  String get unpinCountry => 'Désépingler';

  @override
  String get reorderHint => 'Faites glisser la poignée pour réordonner';

  @override
  String get loadingRates => 'Chargement des taux…';

  @override
  String get ratesLoadFailed =>
      'Impossible de charger les taux en direct. Affichage des données locales.';

  @override
  String get retry => 'Réessayer';

  @override
  String get offlineSeedHint => 'Taux locaux hors ligne';

  @override
  String get rateUnavailable => 'N/D';

  @override
  String get noCountriesOnMap =>
      'Aucune devise visible. Déplacez la carte ou épinglez un pays.';

  @override
  String get amountHint => 'Montant';

  @override
  String get close => 'Fermer';

  @override
  String get aboutTitle => 'À propos de MapRate';

  @override
  String get aboutBody =>
      'MapRate relie une carte du monde aux taux de change en direct. Déplacez la carte pour voir la devise au centre, convertir des montants et épingler des pays pour comparer.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get showTrendChart => 'Afficher le graphique de tendance';

  @override
  String get trendChartTitle => 'Tendance du taux';

  @override
  String get myLocationTooltip => 'Aller à ma position';

  @override
  String get locationPermissionDenied => 'Autorisation de localisation refusée';

  @override
  String get locationServiceDisabled =>
      'Activez les services de localisation pour cette fonction';

  @override
  String get locationFailed => 'Impossible d’obtenir votre position';

  @override
  String get menuAbout => 'À propos';

  @override
  String get menuSettings => 'Réglages';

  @override
  String get adLoading => 'Chargement de la publicité…';

  @override
  String get trendAxisUnit => 'Date (jour)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency pour 1 USD';
  }

  @override
  String get baseInputLabel => 'Saisi';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String updateAvailableBody(String version) {
    return 'La version $version est disponible. Veuillez mettre à jour.';
  }

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateOpenFailed => 'Impossible d’ouvrir le store';

  @override
  String appVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkForUpdate => 'Vérifier les mises à jour';

  @override
  String get updateUpToDate => 'Vous avez la dernière version';

  @override
  String get updateCheckFailed => 'Impossible de vérifier les mises à jour';

  @override
  String get hideExchangeList => 'Masquer les cours';

  @override
  String get showExchangeList => 'Afficher les cours';
}
