import 'dart:convert';
import 'dart:io';

void main() {
  for (final f in Directory('lib/l10n').listSync().whereType<File>()) {
    if (!f.path.endsWith('.arb')) continue;
    try {
      jsonDecode(f.readAsStringSync());
      stdout.writeln('OK ${f.uri.pathSegments.last}');
    } catch (e) {
      stderr.writeln('BAD ${f.path}: $e');
      exitCode = 1;
    }
  }
}
