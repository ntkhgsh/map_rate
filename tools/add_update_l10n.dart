import 'dart:convert';
import 'dart:io';

/// アプリ更新案内の文言を各 ARB に追加する。
void main() {
  // プレースホルダ付きはテンプレート（en）だけ @ メタデータを書く
  final enExtras = <String, Object?>{
    'updateAvailableTitle': 'Update available',
    'updateAvailableBody': 'Version {version} is available. Please update.',
    '@updateAvailableBody': {
      'placeholders': {
        'version': {'type': 'String'},
      },
    },
    'updateNow': 'Update',
    'updateLater': 'Later',
    'updateOpenFailed': 'Could not open the store',
    'appVersionLabel': 'Version {version}',
    '@appVersionLabel': {
      'placeholders': {
        'version': {'type': 'String'},
      },
    },
    'checkForUpdate': 'Check for updates',
    'updateUpToDate': 'You are on the latest version',
    'updateCheckFailed': 'Could not check for updates',
  };

  final translations = <String, Map<String, String>>{
    'updateAvailableTitle': {
      'en': 'Update available',
      'ja': 'アップデートがあります',
      'zh': '有可用更新',
      'zh_TW': '有可用更新',
      'hi': 'अपडेट उपलब्ध है',
      'es': 'Actualización disponible',
      'ko': '업데이트 있음',
      'de': 'Update verfügbar',
      'fr': 'Mise à jour disponible',
      'pt': 'Atualização disponível',
      'pt_BR': 'Atualização disponível',
      'id': 'Pembaruan tersedia',
    },
    'updateAvailableBody': {
      'en': 'Version {version} is available. Please update.',
      'ja': 'バージョン {version} が公開されています。更新してください。',
      'zh': '版本 {version} 已发布，请更新。',
      'zh_TW': '版本 {version} 已發布，請更新。',
      'hi': 'संस्करण {version} उपलब्ध है। कृपया अपडेट करें।',
      'es': 'La versión {version} está disponible. Actualiza la app.',
      'ko': '버전 {version}이(가) 있습니다. 업데이트해 주세요.',
      'de': 'Version {version} ist verfügbar. Bitte aktualisieren.',
      'fr': 'La version {version} est disponible. Veuillez mettre à jour.',
      'pt': 'A versão {version} está disponível. Atualize a app.',
      'pt_BR': 'A versão {version} está disponível. Atualize o app.',
      'id': 'Versi {version} tersedia. Silakan perbarui.',
    },
    'updateNow': {
      'en': 'Update',
      'ja': '更新する',
      'zh': '立即更新',
      'zh_TW': '立即更新',
      'hi': 'अपडेट',
      'es': 'Actualizar',
      'ko': '업데이트',
      'de': 'Aktualisieren',
      'fr': 'Mettre à jour',
      'pt': 'Atualizar',
      'pt_BR': 'Atualizar',
      'id': 'Perbarui',
    },
    'updateLater': {
      'en': 'Later',
      'ja': 'あとで',
      'zh': '稍后',
      'zh_TW': '稍後',
      'hi': 'बाद में',
      'es': 'Más tarde',
      'ko': '나중에',
      'de': 'Später',
      'fr': 'Plus tard',
      'pt': 'Mais tarde',
      'pt_BR': 'Mais tarde',
      'id': 'Nanti',
    },
    'updateOpenFailed': {
      'en': 'Could not open the store',
      'ja': 'ストアを開けませんでした',
      'zh': '无法打开商店',
      'zh_TW': '無法開啟商店',
      'hi': 'स्टोर नहीं खुल सका',
      'es': 'No se pudo abrir la tienda',
      'ko': '스토어를 열 수 없습니다',
      'de': 'Store konnte nicht geöffnet werden',
      'fr': 'Impossible d’ouvrir le store',
      'pt': 'Não foi possível abrir a loja',
      'pt_BR': 'Não foi possível abrir a loja',
      'id': 'Tidak bisa membuka toko',
    },
    'appVersionLabel': {
      'en': 'Version {version}',
      'ja': 'バージョン {version}',
      'zh': '版本 {version}',
      'zh_TW': '版本 {version}',
      'hi': 'संस्करण {version}',
      'es': 'Versión {version}',
      'ko': '버전 {version}',
      'de': 'Version {version}',
      'fr': 'Version {version}',
      'pt': 'Versão {version}',
      'pt_BR': 'Versão {version}',
      'id': 'Versi {version}',
    },
    'checkForUpdate': {
      'en': 'Check for updates',
      'ja': 'アップデートを確認',
      'zh': '检查更新',
      'zh_TW': '檢查更新',
      'hi': 'अपडेट जांचें',
      'es': 'Buscar actualizaciones',
      'ko': '업데이트 확인',
      'de': 'Nach Updates suchen',
      'fr': 'Vérifier les mises à jour',
      'pt': 'Procurar atualizações',
      'pt_BR': 'Verificar atualizações',
      'id': 'Periksa pembaruan',
    },
    'updateUpToDate': {
      'en': 'You are on the latest version',
      'ja': '最新バージョンです',
      'zh': '已是最新版本',
      'zh_TW': '已是最新版本',
      'hi': 'आप नवीनतम संस्करण पर हैं',
      'es': 'Ya tienes la última versión',
      'ko': '최신 버전입니다',
      'de': 'Sie nutzen die neueste Version',
      'fr': 'Vous avez la dernière version',
      'pt': 'Já tem a versão mais recente',
      'pt_BR': 'Você está na versão mais recente',
      'id': 'Anda memakai versi terbaru',
    },
    'updateCheckFailed': {
      'en': 'Could not check for updates',
      'ja': 'アップデートを確認できませんでした',
      'zh': '无法检查更新',
      'zh_TW': '無法檢查更新',
      'hi': 'अपडेट जाँच नहीं हो सकी',
      'es': 'No se pudieron buscar actualizaciones',
      'ko': '업데이트를 확인할 수 없습니다',
      'de': 'Update-Prüfung fehlgeschlagen',
      'fr': 'Impossible de vérifier les mises à jour',
      'pt': 'Não foi possível procurar atualizações',
      'pt_BR': 'Não foi possível verificar atualizações',
      'id': 'Tidak bisa memeriksa pembaruan',
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
    if (map is! Map) {
      stderr.writeln('skip ${entry.key}: not a map');
      continue;
    }
    final data = Map<String, Object?>.from(map);

    if (locale == 'en') {
      data.addAll(enExtras);
    } else {
      for (final keyEntry in translations.entries) {
        data[keyEntry.key] = keyEntry.value[locale] ?? keyEntry.value['en']!;
      }
    }

    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync('${encoder.convert(data)}\n', encoding: utf8);
    stdout.writeln('updated ${entry.key}');
  }
}
