import 'dart:convert';
import 'dart:io';

void main() {
  final translations = <String, Map<String, String>>{
    'adRetryFailed': {
      'en':
          'Still couldn’t load the ad. If you use an ad blocker, allow MapRate, then retry.',
      'ja':
          '再試行しましたが広告を取得できませんでした。広告ブロックを使っている場合は MapRate を許可してから、もう一度お試しください。',
      'zh': '仍无法加载广告。若使用广告拦截，请允许 MapRate 后重试。',
      'zh_TW': '仍無法載入廣告。若使用廣告封鎖，請允許 MapRate 後再試。',
      'hi':
          'विज्ञापन अभी भी लोड नहीं हुआ। ऐड ब्लॉकर हो तो MapRate अनुमति देकर फिर कोशिश करें।',
      'es':
          'Aún no se pudo cargar el anuncio. Si usas un bloqueador, permite MapRate y reintenta.',
      'ko': '광고를 불러오지 못했습니다. 광고 차단을 쓰는 경우 MapRate를 허용한 뒤 다시 시도하세요.',
      'de':
          'Anzeige konnte weiterhin nicht geladen werden. Bei Werbeblocker MapRate erlauben und erneut versuchen.',
      'fr':
          'Impossible de charger l’annonce. Si vous utilisez un bloqueur, autorisez MapRate puis réessayez.',
      'pt':
          'Ainda não foi possível carregar o anúncio. Se usa bloqueador, permita o MapRate e tente de novo.',
      'pt_BR':
          'Ainda não foi possível carregar o anúncio. Se usa bloqueador, permita o MapRate e tente de novo.',
      'id':
          'Iklan masih gagal dimuat. Jika memakai pemblokir, izinkan MapRate lalu coba lagi.',
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
