import 'dart:convert';
import 'dart:io';

void main() {
  final fixes = <String, String>{
    'app_en.arb': 'Entered',
    'app_ja.arb': '入力中',
    'app_zh.arb': '已输入',
    'app_zh_TW.arb': '已輸入',
    'app_hi.arb': 'दर्ज',
    'app_es.arb': 'Introducido',
    'app_ko.arb': '입력됨',
    'app_de.arb': 'Eingabe',
    'app_fr.arb': 'Saisi',
    'app_pt.arb': 'Introduzido',
    'app_pt_BR.arb': 'Digitado',
    'app_id.arb': 'Diinput',
  };

  for (final entry in fixes.entries) {
    final file = File('lib/l10n/${entry.key}');
    var text = file.readAsStringSync(encoding: utf8);
    if (text.contains('"baseInputLabel"')) {
      text = text.replaceAllMapped(
        RegExp(r'"baseInputLabel"\s*:\s*"[^"]*"'),
        (_) => '"baseInputLabel": "${entry.value}"',
      );
    } else {
      text = text.trimRight();
      if (text.endsWith('}')) {
        text = text.substring(0, text.length - 1).trimRight();
        if (!text.endsWith(',')) text = '$text,';
        text = '$text\n  "baseInputLabel": "${entry.value}"\n}\n';
      }
    }
    file.writeAsStringSync(text, encoding: utf8);
    stdout.writeln('updated ${entry.key}');
  }
}
