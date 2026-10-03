import 'dart:convert';
import 'dart:io';

void main() {
  final fixes = <String, String>{
    'app_en.arb': 'Date (day)',
    'app_ja.arb': '日付（日）',
    'app_zh.arb': '日期（日）',
    'app_zh_TW.arb': '日期（日）',
    'app_hi.arb': 'तिथि (दिन)',
    'app_es.arb': 'Fecha (día)',
    'app_ko.arb': '날짜(일)',
    'app_de.arb': 'Datum (Tag)',
    'app_fr.arb': 'Date (jour)',
    'app_pt.arb': 'Data (dia)',
    'app_pt_BR.arb': 'Data (dia)',
    'app_id.arb': 'Tanggal (hari)',
  };

  for (final entry in fixes.entries) {
    final file = File('lib/l10n/${entry.key}');
    var text = file.readAsStringSync(encoding: utf8);
    if (text.contains('"trendAxisUnit"')) {
      text = text.replaceAllMapped(
        RegExp(r'"trendAxisUnit"\s*:\s*"[^"]*"'),
        (_) => '"trendAxisUnit": "${entry.value}"',
      );
    } else {
      text = text.trimRight();
      if (text.endsWith('}')) {
        text = text.substring(0, text.length - 1).trimRight();
        if (!text.endsWith(',')) {
          text = '$text,';
        }
        text = '$text\n  "trendAxisUnit": "${entry.value}"\n}\n';
      }
    }
    file.writeAsStringSync(text, encoding: utf8);
    stdout.writeln('fixed ${entry.key} -> ${entry.value}');
  }
}
