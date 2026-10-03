import 'dart:convert';
import 'dart:io';

void main() {
  final translations = <String, Map<String, String>>{
    'hideExchangeList': {
      'en': 'Hide rates',
      'ja': '為替リストを隠す',
      'zh': '隐藏汇率列表',
      'zh_TW': '隱藏匯率列表',
      'hi': 'दरें छिपाएँ',
      'es': 'Ocultar tipos',
      'ko': '환율 목록 숨기기',
      'de': 'Kurse ausblenden',
      'fr': 'Masquer les cours',
      'pt': 'Ocultar taxas',
      'pt_BR': 'Ocultar cotações',
      'id': 'Sembunyikan kurs',
    },
    'showExchangeList': {
      'en': 'Show rates',
      'ja': '為替リストを表示',
      'zh': '显示汇率列表',
      'zh_TW': '顯示匯率列表',
      'hi': 'दरें दिखाएँ',
      'es': 'Mostrar tipos',
      'ko': '환율 목록 보기',
      'de': 'Kurse anzeigen',
      'fr': 'Afficher les cours',
      'pt': 'Mostrar taxas',
      'pt_BR': 'Mostrar cotações',
      'id': 'Tampilkan kurs',
    },
  };

  final fileLocale = <String, String>{
    'app_en.arb': 'en',
    'app_ja.arb': 'ja',
    'app_zh.arb': 'zh',
    'app_zh_TW.arb': 'zh_TW',
    'app_hi.arb': 'hi',
    'app_es.arb': 'es',
    'app_ko.arb': 'ko',
    'app_de.arb': 'de',
    'app_fr.arb': 'fr',
    'app_pt.arb': 'pt',
    'app_pt_BR.arb': 'pt_BR',
    'app_id.arb': 'id',
  };

  for (final entry in fileLocale.entries) {
    final file = File('lib/l10n/${entry.key}');
    final locale = entry.value;
    final map = jsonDecode(file.readAsStringSync(encoding: utf8));
    if (map is! Map) continue;
    final data = Map<String, Object?>.from(map);
    for (final keyEntry in translations.entries) {
      data[keyEntry.key] = keyEntry.value[locale] ?? keyEntry.value['en']!;
    }
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync('${encoder.convert(data)}\n', encoding: utf8);
    stdout.writeln('updated ${entry.key}');
  }
}
