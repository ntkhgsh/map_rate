import 'dart:convert';
import 'dart:io';

void main() {
  final translations = <String, Map<String, String>>{
    'adBlocksInputHint': {
      'en': 'Allow ads to edit exchange amounts.',
      'ja': '広告を許可すると、為替の金額を入力できます。',
      'zh': '允许广告后即可输入汇率金额。',
      'zh_TW': '允許廣告後即可輸入匯率金額。',
      'hi': 'राशि बदलने के लिए विज्ञापन अनुमति दें।',
      'es': 'Permite los anuncios para editar los importes.',
      'ko': '광고를 허용하면 환율 금액을 입력할 수 있습니다.',
      'de': 'Anzeigen erlauben, um Beträge zu bearbeiten.',
      'fr': 'Autorisez les annonces pour modifier les montants.',
      'pt': 'Permita anúncios para editar os valores.',
      'pt_BR': 'Permita anúncios para editar os valores.',
      'id': 'Izinkan iklan untuk mengubah jumlah kurs.',
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
