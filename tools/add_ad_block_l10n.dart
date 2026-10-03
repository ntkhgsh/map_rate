import 'dart:convert';
import 'dart:io';

void main() {
  final keys = <String, Map<String, String>>{
    'adBlockedTitle': {
      'en': 'Ads are blocked',
      'ja': '広告がブロックされています',
      'zh': '广告被拦截',
      'zh_TW': '廣告被封鎖',
      'hi': 'विज्ञापन ब्लॉक हैं',
      'es': 'Anuncios bloqueados',
      'ko': '광고가 차단됨',
      'de': 'Werbung blockiert',
      'fr': 'Annonces bloquées',
      'pt': 'Anúncios bloqueados',
      'pt_BR': 'Anúncios bloqueados',
      'id': 'Iklan diblokir',
    },
    'adBlockedBody': {
      'en':
          'MapRate is free thanks to ads. An ad blocker or VPN (such as AdGuard) may be blocking AdMob. Please allow this app or Google ads domains, then tap Retry.',
      'ja':
          'MapRate は広告で無料提供しています。AdGuard などの広告ブロックや VPN が AdMob を遮断している可能性があります。このアプリまたは Google 広告の通信を許可してから「再試行」を押してください。',
      'zh':
          'MapRate 靠广告免费提供。广告拦截或 VPN（如 AdGuard）可能拦截了 AdMob。请允许本应用或 Google 广告域名后点击重试。',
      'zh_TW':
          'MapRate 靠廣告免費提供。廣告封鎖或 VPN（如 AdGuard）可能攔截了 AdMob。請允許本應用或 Google 廣告網域後點重試。',
      'hi':
          'MapRate विज्ञापनों से मुफ़्त है। ऐड ब्लॉकर/VPN (जैसे AdGuard) AdMob रोक सकता है। ऐप या Google विज्ञापन अनुमति दें, फिर Retry दबाएँ।',
      'es':
          'MapRate es gratis gracias a los anuncios. Un bloqueador o VPN (p. ej. AdGuard) puede estar bloqueando AdMob. Permite esta app o los dominios de Google Ads y pulsa Reintentar.',
      'ko':
          'MapRate는 광고로 무료 제공됩니다. AdGuard 등 광고 차단/VPN이 AdMob을 막을 수 있습니다. 이 앱 또는 Google 광고를 허용한 뒤 다시 시도하세요.',
      'de':
          'MapRate ist dank Werbung kostenlos. Ein Werbeblocker oder VPN (z. B. AdGuard) blockiert möglicherweise AdMob. Erlauben Sie die App bzw. Google Ads und tippen Sie auf Erneut versuchen.',
      'fr':
          'MapRate est gratuit grâce aux annonces. Un bloqueur ou VPN (ex. AdGuard) peut bloquer AdMob. Autorisez cette appli ou les domaines Google Ads, puis réessayez.',
      'pt':
          'O MapRate é gratuito graças aos anúncios. Um bloqueador ou VPN (ex. AdGuard) pode estar a bloquear o AdMob. Permita esta app ou os domínios Google Ads e toque em Tentar novamente.',
      'pt_BR':
          'O MapRate é gratuito graças aos anúncios. Um bloqueador ou VPN (ex. AdGuard) pode estar bloqueando o AdMob. Permita este app ou os domínios do Google Ads e toque em Tentar novamente.',
      'id':
          'MapRate gratis berkat iklan. Pemblokir iklan atau VPN (mis. AdGuard) mungkin memblokir AdMob. Izinkan aplikasi ini atau domain iklan Google, lalu ketuk Coba lagi.',
    },
    'adWhitelistHint': {
      'en':
          'AdGuard tip: Apps management → MapRate → disable filtering, or add googleads.g.doubleclick.net and googlesyndication.com to allowlist.',
      'ja':
          'AdGuard の例: アプリ管理 → MapRate → フィルタリングをオフ。または googleads.g.doubleclick.net と googlesyndication.com を許可リストへ。',
      'zh':
          'AdGuard：应用管理 → MapRate → 关闭过滤；或将 googleads.g.doubleclick.net、googlesyndication.com 加入白名单。',
      'zh_TW':
          'AdGuard：應用程式管理 → MapRate → 關閉過濾；或將 googleads.g.doubleclick.net、googlesyndication.com 加入允許清單。',
      'hi':
          'AdGuard: Apps management → MapRate → filtering बंद करें, या googleads.g.doubleclick.net / googlesyndication.com allowlist में डालें।',
      'es':
          'AdGuard: Gestión de apps → MapRate → desactiva el filtrado, o añade googleads.g.doubleclick.net y googlesyndication.com a la lista blanca.',
      'ko':
          'AdGuard: 앱 관리 → MapRate → 필터링 끄기. 또는 googleads.g.doubleclick.net, googlesyndication.com을 허용 목록에 추가.',
      'de':
          'AdGuard: App-Verwaltung → MapRate → Filterung aus, oder googleads.g.doubleclick.net und googlesyndication.com zur Freigabeliste.',
      'fr':
          'AdGuard : Gestion des applis → MapRate → désactiver le filtrage, ou autoriser googleads.g.doubleclick.net et googlesyndication.com.',
      'pt':
          'AdGuard: Gestão de apps → MapRate → desative a filtragem, ou permita googleads.g.doubleclick.net e googlesyndication.com.',
      'pt_BR':
          'AdGuard: Gerenciar apps → MapRate → desative a filtragem, ou permita googleads.g.doubleclick.net e googlesyndication.com.',
      'id':
          'AdGuard: Manajemen aplikasi → MapRate → nonaktifkan filter, atau izinkan googleads.g.doubleclick.net dan googlesyndication.com.',
    },
    'adRetry': {
      'en': 'Retry',
      'ja': '再試行',
      'zh': '重试',
      'zh_TW': '重試',
      'hi': 'फिर कोशिश',
      'es': 'Reintentar',
      'ko': '다시 시도',
      'de': 'Erneut',
      'fr': 'Réessayer',
      'pt': 'Tentar novamente',
      'pt_BR': 'Tentar novamente',
      'id': 'Coba lagi',
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
    var text = file.readAsStringSync(encoding: utf8);
    final locale = entry.value;
    for (final keyEntry in keys.entries) {
      final key = keyEntry.key;
      final value = keyEntry.value[locale] ?? keyEntry.value['en']!;
      final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      if (text.contains('"$key"')) {
        text = text.replaceAllMapped(
          RegExp('"$key"\\s*:\\s*"[^"]*"'),
          (_) => '"$key": "$escaped"',
        );
      } else {
        text = text.trimRight();
        if (text.endsWith('}')) {
          text = text.substring(0, text.length - 1).trimRight();
          if (!text.endsWith(',')) text = '$text,';
          text = '$text\n  "$key": "$escaped"\n}\n';
        }
      }
    }
    // 閉じ括弧前のカンマ整形
    text = text.replaceAllMapped(
      RegExp(r',(\s*)}'),
      (m) => '${m[1]}}',
    );
    // 最後のプロパティのあとに } だけにする（キー追加時に } を付けている）
    file.writeAsStringSync(text, encoding: utf8);
    stdout.writeln('updated ${entry.key}');
  }
}
