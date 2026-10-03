// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Moeda no centro do mapa';

  @override
  String get resolving => 'A procurar…';

  @override
  String get moveMapHint =>
      'Mova o mapa para detetar o país e a moeda no centro.';

  @override
  String countryCodeLabel(String code) {
    return 'Código do país $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Moeda $label';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get invalidCoordinates => 'Latitude ou longitude inválida';

  @override
  String get geocoderUnavailable =>
      'Este dispositivo não consegue identificar países';

  @override
  String get countryNotFound =>
      'Não foi possível identificar o país neste local';

  @override
  String get countryLookupFailed =>
      'Não foi possível obter informação do país. Verifique a ligação.';

  @override
  String get exchangeListTitle => 'Taxas de câmbio no mapa';

  @override
  String updatedAt(String time) {
    return 'Atualizado: $time';
  }

  @override
  String rateDate(String date) {
    return 'Data da taxa: $date';
  }

  @override
  String get notUpdatedYet => 'Ainda não atualizado';

  @override
  String get dataSourceTitle => 'Sobre os dados de câmbio';

  @override
  String get dataSourceBody =>
      'O MapRate carrega taxas médias da ExchangeRate-API (open.er-api.com), depois um feed CDN e Frankfurter. Os montantes convertem via USD. Os gráficos usam histórico Frankfurter quando disponível. Taxas indicativas, não cotações de negociação.';

  @override
  String get pinCountry => 'Fixar';

  @override
  String get unpinCountry => 'Desafixar';

  @override
  String get reorderHint => 'Arraste o indicador para reordenar';

  @override
  String get loadingRates => 'A carregar taxas…';

  @override
  String get ratesLoadFailed =>
      'Não foi possível carregar taxas em direto. A mostrar dados locais.';

  @override
  String get retry => 'Repetir';

  @override
  String get offlineSeedHint => 'Taxas locais offline';

  @override
  String get rateUnavailable => 'N/D';

  @override
  String get noCountriesOnMap =>
      'Sem moedas visíveis. Mova o mapa ou fixe um país.';

  @override
  String get amountHint => 'Montante';

  @override
  String get close => 'Fechar';

  @override
  String get aboutTitle => 'Sobre o MapRate';

  @override
  String get aboutBody =>
      'O MapRate liga um mapa mundial a taxas de câmbio em direto. Mova o mapa para ver a moeda no centro, converter montantes e fixar países para comparar.';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Predefinição do sistema';

  @override
  String get showTrendChart => 'Mostrar gráfico de tendência';

  @override
  String get trendChartTitle => 'Tendência da taxa';

  @override
  String get myLocationTooltip => 'Ir para a minha localização';

  @override
  String get locationPermissionDenied => 'Permissão de localização recusada';

  @override
  String get locationServiceDisabled =>
      'Ative os serviços de localização para usar esta funcionalidade';

  @override
  String get locationFailed => 'Não foi possível obter a sua localização';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get menuSettings => 'Definições';

  @override
  String get adLoading => 'A carregar anúncio…';

  @override
  String get trendAxisUnit => 'Data (dia)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency por 1 USD';
  }

  @override
  String get baseInputLabel => 'Introduzido';

  @override
  String get updateAvailableTitle => 'Atualização disponível';

  @override
  String updateAvailableBody(String version) {
    return 'A versão $version está disponível. Atualize a app.';
  }

  @override
  String get updateNow => 'Atualizar';

  @override
  String get updateLater => 'Mais tarde';

  @override
  String get updateOpenFailed => 'Não foi possível abrir a loja';

  @override
  String appVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get checkForUpdate => 'Procurar atualizações';

  @override
  String get updateUpToDate => 'Já tem a versão mais recente';

  @override
  String get updateCheckFailed => 'Não foi possível procurar atualizações';

  @override
  String get hideExchangeList => 'Ocultar taxas';

  @override
  String get showExchangeList => 'Mostrar taxas';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Moeda no centro do mapa';

  @override
  String get resolving => 'Consultando…';

  @override
  String get moveMapHint =>
      'Mova o mapa para detectar o país e a moeda no centro.';

  @override
  String countryCodeLabel(String code) {
    return 'Código do país $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Moeda $label';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get invalidCoordinates => 'Latitude ou longitude inválida';

  @override
  String get geocoderUnavailable =>
      'Este dispositivo não consegue identificar países';

  @override
  String get countryNotFound =>
      'Não foi possível identificar o país neste local';

  @override
  String get countryLookupFailed =>
      'Não foi possível obter informações do país. Verifique a conexão.';

  @override
  String get exchangeListTitle => 'Câmbio no mapa';

  @override
  String updatedAt(String time) {
    return 'Atualizado: $time';
  }

  @override
  String rateDate(String date) {
    return 'Data da taxa: $date';
  }

  @override
  String get notUpdatedYet => 'Ainda não atualizado';

  @override
  String get dataSourceTitle => 'Sobre os dados de câmbio';

  @override
  String get dataSourceBody =>
      'O MapRate carrega taxas médias da ExchangeRate-API (open.er-api.com), depois um feed CDN e Frankfurter. Os valores são convertidos via USD. Os gráficos usam histórico Frankfurter quando disponível. Taxas indicativas, não cotações de negociação.';

  @override
  String get pinCountry => 'Fixar';

  @override
  String get unpinCountry => 'Desfixar';

  @override
  String get reorderHint => 'Arraste a alça para reordenar';

  @override
  String get loadingRates => 'Carregando taxas…';

  @override
  String get ratesLoadFailed =>
      'Não foi possível carregar taxas ao vivo. Exibindo dados locais.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get offlineSeedHint => 'Taxas locais offline';

  @override
  String get rateUnavailable => 'N/D';

  @override
  String get noCountriesOnMap =>
      'Nenhuma moeda visível. Mova o mapa ou fixe um país.';

  @override
  String get amountHint => 'Valor';

  @override
  String get close => 'Fechar';

  @override
  String get aboutTitle => 'Sobre o MapRate';

  @override
  String get aboutBody =>
      'O MapRate conecta um mapa mundial a taxas de câmbio ao vivo. Mova o mapa para ver a moeda no centro, converter valores e fixar países para comparar.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get showTrendChart => 'Mostrar gráfico de tendência';

  @override
  String get trendChartTitle => 'Tendência da taxa';

  @override
  String get myLocationTooltip => 'Ir para minha localização';

  @override
  String get locationPermissionDenied => 'Permissão de localização negada';

  @override
  String get locationServiceDisabled =>
      'Ative os serviços de localização para usar este recurso';

  @override
  String get locationFailed => 'Não foi possível obter sua localização';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get adLoading => 'Carregando anúncio…';

  @override
  String get trendAxisUnit => 'Data (dia)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency por 1 USD';
  }

  @override
  String get baseInputLabel => 'Digitado';

  @override
  String get updateAvailableTitle => 'Atualização disponível';

  @override
  String updateAvailableBody(String version) {
    return 'A versão $version está disponível. Atualize o app.';
  }

  @override
  String get updateNow => 'Atualizar';

  @override
  String get updateLater => 'Mais tarde';

  @override
  String get updateOpenFailed => 'Não foi possível abrir a loja';

  @override
  String appVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get checkForUpdate => 'Verificar atualizações';

  @override
  String get updateUpToDate => 'Você está na versão mais recente';

  @override
  String get updateCheckFailed => 'Não foi possível verificar atualizações';

  @override
  String get hideExchangeList => 'Ocultar cotações';

  @override
  String get showExchangeList => 'Mostrar cotações';
}
