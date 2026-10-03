import 'dart:convert';
import 'dart:io';

void main() {
  // 縦軸単位: 1 USD あたりのその通貨の量
  final fixes = <String, String>{
    'app_en.arb': '{currency} per 1 USD',
    'app_ja.arb': '1 USDあたりの{currency}',
    'app_zh.arb': '每 1 USD 的 {currency}',
    'app_zh_TW.arb': '每 1 USD 的 {currency}',
    'app_hi.arb': '1 USD पर {currency}',
    'app_es.arb': '{currency} por 1 USD',
    'app_ko.arb': 'USD 1당 {currency}',
    'app_de.arb': '{currency} je 1 USD',
    'app_fr.arb': '{currency} pour 1 USD',
    'app_pt.arb': '{currency} por 1 USD',
    'app_pt_BR.arb': '{currency} por 1 USD',
    'app_id.arb': '{currency} per 1 USD',
  };

  const meta = '''
  "@trendYAxisUnit": {
    "placeholders": {
      "currency": {"type": "String"}
    }
  }''';

  for (final entry in fixes.entries) {
    final file = File('lib/l10n/${entry.key}');
    var text = file.readAsStringSync(encoding: utf8);

    // 既存キーがあれば値だけ更新、なければ末尾に追加
    if (text.contains('"trendYAxisUnit"')) {
      text = text.replaceAllMapped(
        RegExp(r'"trendYAxisUnit"\s*:\s*"[^"]*"'),
        (_) => '"trendYAxisUnit": "${entry.value}"',
      );
    } else {
      text = text.trimRight();
      if (text.endsWith('}')) {
        text = text.substring(0, text.length - 1).trimRight();
        if (!text.endsWith(',')) {
          text = '$text,';
        }
        text = '$text\n  "trendYAxisUnit": "${entry.value}",\n$meta\n}\n';
      }
    }
    file.writeAsStringSync(text, encoding: utf8);
    stdout.writeln('updated ${entry.key}');
  }
}
