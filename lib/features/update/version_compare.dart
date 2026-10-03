/// セマンティック版数を比較する。
///
/// 戻り値: [a] > [b] なら正、等しければ 0、[a] < [b] なら負。
/// `1.2` と `1.2.0` は同じとみなす。ビルド番号（`+1`）は無視する。
int compareVersions(String a, String b) {
  final left = _parse(a);
  final right = _parse(b);
  final len = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < len; i++) {
    final lv = i < left.length ? left[i] : 0;
    final rv = i < right.length ? right[i] : 0;
    if (lv != rv) return lv.compareTo(rv);
  }
  return 0;
}

/// タイトル横用の短い版表示。
///
/// 例: `0.0.1` → `v1`、`1.2.0` → `v1`、`0.3.2` → `v3`
String formatDisplayVersion(String version) {
  final parts = _parse(version);
  final major = parts.isNotEmpty ? parts[0] : 0;
  final minor = parts.length > 1 ? parts[1] : 0;
  final patch = parts.length > 2 ? parts[2] : 0;
  if (major > 0) return 'v$major';
  if (minor > 0) return 'v$minor';
  return 'v$patch';
}

List<int> _parse(String raw) {
  var text = raw.trim();
  final plus = text.indexOf('+');
  if (plus >= 0) text = text.substring(0, plus);
  final dash = text.indexOf('-');
  if (dash >= 0) text = text.substring(0, dash);
  if (text.isEmpty) return const [0];
  return text.split('.').map((part) {
    final digits = RegExp(r'^\d+').firstMatch(part)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }).toList(growable: false);
}
