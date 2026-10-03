// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Moneda en el centro del mapa';

  @override
  String get resolving => 'Buscando…';

  @override
  String get moveMapHint =>
      'Mueva el mapa para detectar el país y la moneda en el centro.';

  @override
  String countryCodeLabel(String code) {
    return 'Código de país $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Moneda $label';
  }

  @override
  String get unknown => 'Desconocido';

  @override
  String get invalidCoordinates => 'Latitud o longitud no válida';

  @override
  String get geocoderUnavailable => 'Este dispositivo no puede buscar países';

  @override
  String get countryNotFound =>
      'No se pudo identificar el país en esta ubicación';

  @override
  String get countryLookupFailed =>
      'No se pudo obtener información del país. Compruebe la conexión.';

  @override
  String get exchangeListTitle => 'Tipos de cambio en el mapa';

  @override
  String updatedAt(String time) {
    return 'Actualizado: $time';
  }

  @override
  String rateDate(String date) {
    return 'Fecha del tipo: $date';
  }

  @override
  String get notUpdatedYet => 'Aún no actualizado';

  @override
  String get dataSourceTitle => 'Sobre los datos de cambio';

  @override
  String get dataSourceBody =>
      'MapRate carga tipos medios de ExchangeRate-API (open.er-api.com), luego un feed CDN y Frankfurter. Los importes se convierten vía USD. Los gráficos usan historial de Frankfurter cuando está disponible. Tipos orientativos, no cotizaciones de trading.';

  @override
  String get pinCountry => 'Fijar';

  @override
  String get unpinCountry => 'Quitar fijación';

  @override
  String get reorderHint => 'Arrastre el control para reordenar';

  @override
  String get loadingRates => 'Cargando tipos…';

  @override
  String get ratesLoadFailed =>
      'No se pudieron cargar tipos en vivo. Mostrando datos locales.';

  @override
  String get retry => 'Reintentar';

  @override
  String get offlineSeedHint => 'Tipos locales sin conexión';

  @override
  String get rateUnavailable => 'N/D';

  @override
  String get noCountriesOnMap =>
      'No hay monedas visibles. Mueva el mapa o fije un país.';

  @override
  String get amountHint => 'Importe';

  @override
  String get close => 'Cerrar';

  @override
  String get aboutTitle => 'Acerca de MapRate';

  @override
  String get aboutBody =>
      'MapRate vincula un mapa mundial con tipos de cambio en vivo. Mueva el mapa para ver la moneda del país en el centro, convertir importes y fijar países para comparar.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get showTrendChart => 'Mostrar gráfico de tendencia';

  @override
  String get trendChartTitle => 'Tendencia del tipo';

  @override
  String get myLocationTooltip => 'Ir a mi ubicación';

  @override
  String get locationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get locationServiceDisabled =>
      'Active los servicios de ubicación para usar esta función';

  @override
  String get locationFailed => 'No se pudo obtener su ubicación';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get adLoading => 'Cargando anuncio…';

  @override
  String get trendAxisUnit => 'Fecha (día)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency por 1 USD';
  }

  @override
  String get baseInputLabel => 'Introducido';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String updateAvailableBody(String version) {
    return 'La versión $version está disponible. Actualiza la app.';
  }

  @override
  String get updateNow => 'Actualizar';

  @override
  String get updateLater => 'Más tarde';

  @override
  String get updateOpenFailed => 'No se pudo abrir la tienda';

  @override
  String appVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get checkForUpdate => 'Buscar actualizaciones';

  @override
  String get updateUpToDate => 'Ya tienes la última versión';

  @override
  String get updateCheckFailed => 'No se pudieron buscar actualizaciones';

  @override
  String get hideExchangeList => 'Ocultar tipos';

  @override
  String get showExchangeList => 'Mostrar tipos';
}
