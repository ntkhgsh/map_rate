/// 画面に出す通貨の情報。
///
/// [code] は ISO 4217（例: JPY）。
/// [symbol] は一般的な記号。記号が広く使われていない通貨は [code] と同じ文字にする。
/// [nameJa] は日本語名。日本語名を置かない場合は [code] と同じ文字にする。
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.nameJa,
  });

  final String code;
  final String symbol;
  final String nameJa;

  /// カードに出す文言。例: `JPY（¥）日本円`
  String get label {
    final hasSymbol = symbol != code;
    final hasName = nameJa.isNotEmpty && nameJa != code;
    if (hasSymbol && hasName) {
      return '$code（$symbol）$nameJa';
    }
    if (hasSymbol) {
      return '$code（$symbol）';
    }
    if (hasName) {
      return '$code $nameJa';
    }
    return code;
  }
}

/// 端末や地図から来た国コードを、ISO 3166-1 alpha-2 の2文字に整える。
///
/// 不正な値は null。`UK` はよく使われる俗称なので `GB` に直す。
String? normalizeCountryCode(String? raw) {
  if (raw == null) return null;
  final upper = raw.trim().toUpperCase();
  final code = _countryCodeAliases[upper] ?? upper;
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
    return null;
  }
  return code;
}

/// 国コードから国旗の絵文字を作る。2文字の英字以外は null。
String? flagEmojiFromCountryCode(String? raw) {
  final code = normalizeCountryCode(raw);
  if (code == null) return null;
  final first = code.codeUnitAt(0);
  final second = code.codeUnitAt(1);
  // 地域指標記号は A が U+1F1E6
  return String.fromCharCodes([
    0x1F1E6 + (first - 0x41),
    0x1F1E6 + (second - 0x41),
  ]);
}

/// 国コードに対応する主通貨。表に無い国は null（画面では「不明」）。
CurrencyInfo? currencyForCountryCode(String? raw) {
  final code = normalizeCountryCode(raw);
  if (code == null) return null;
  return countryCurrencyTable[code];
}

/// 逆ジオコーディングが返す国名から、表示に使えない文字を除く。
///
/// 空、または制御文字だけの場合は null。長すぎる文字列は80文字で切る。
String? sanitizePlaceName(String? raw) {
  if (raw == null) return null;
  final buffer = StringBuffer();
  for (final rune in raw.runes) {
    // 改行やヌル文字など、画面を崩す制御文字は捨てる
    if (rune <= 0x1F || rune == 0x7F) continue;
    buffer.writeCharCode(rune);
  }
  final text = buffer.toString().trim();
  if (text.isEmpty) return null;
  if (text.length <= 80) return text;
  return text.substring(0, 80);
}

const _countryCodeAliases = <String, String>{
  'UK': 'GB',
};

const _jpy = CurrencyInfo(code: 'JPY', symbol: '¥', nameJa: '日本円');
const _usd = CurrencyInfo(code: 'USD', symbol: r'$', nameJa: '米ドル');
const _eur = CurrencyInfo(code: 'EUR', symbol: '€', nameJa: 'ユーロ');
const _gbp = CurrencyInfo(code: 'GBP', symbol: '£', nameJa: '英ポンド');
const _aud = CurrencyInfo(code: 'AUD', symbol: r'A$', nameJa: '豪ドル');
const _nzd = CurrencyInfo(code: 'NZD', symbol: r'NZ$', nameJa: 'ニュージーランド・ドル');
const _cad = CurrencyInfo(code: 'CAD', symbol: r'C$', nameJa: 'カナダ・ドル');
const _chf = CurrencyInfo(code: 'CHF', symbol: 'Fr', nameJa: 'スイス・フラン');
const _cny = CurrencyInfo(code: 'CNY', symbol: '¥', nameJa: '人民元');
const _hkd = CurrencyInfo(code: 'HKD', symbol: r'HK$', nameJa: '香港ドル');
const _mop = CurrencyInfo(code: 'MOP', symbol: r'MOP$', nameJa: 'マカオ・パタカ');
const _twd = CurrencyInfo(code: 'TWD', symbol: r'NT$', nameJa: '新台湾ドル');
const _krw = CurrencyInfo(code: 'KRW', symbol: '₩', nameJa: '韓国ウォン');
const _thb = CurrencyInfo(code: 'THB', symbol: '฿', nameJa: 'タイ・バーツ');
const _vnd = CurrencyInfo(code: 'VND', symbol: '₫', nameJa: 'ベトナム・ドン');
const _sgd = CurrencyInfo(code: 'SGD', symbol: r'S$', nameJa: 'シンガポール・ドル');
const _myr = CurrencyInfo(code: 'MYR', symbol: 'RM', nameJa: 'マレーシア・リンギット');
const _idr = CurrencyInfo(code: 'IDR', symbol: 'Rp', nameJa: 'インドネシア・ルピア');
const _php = CurrencyInfo(code: 'PHP', symbol: '₱', nameJa: 'フィリピン・ペソ');
const _inr = CurrencyInfo(code: 'INR', symbol: '₹', nameJa: 'インド・ルピー');
const _dkk = CurrencyInfo(code: 'DKK', symbol: 'kr', nameJa: 'デンマーク・クローネ');
const _nok = CurrencyInfo(code: 'NOK', symbol: 'kr', nameJa: 'ノルウェー・クローネ');
const _sek = CurrencyInfo(code: 'SEK', symbol: 'kr', nameJa: 'スウェーデン・クローナ');
const _pln = CurrencyInfo(code: 'PLN', symbol: 'zł', nameJa: 'ポーランド・ズウォティ');
const _czk = CurrencyInfo(code: 'CZK', symbol: 'Kč', nameJa: 'チェコ・コルナ');
const _huf = CurrencyInfo(code: 'HUF', symbol: 'Ft', nameJa: 'ハンガリー・フォリント');
const _ron = CurrencyInfo(code: 'RON', symbol: 'lei', nameJa: 'ルーマニア・レイ');
const _try = CurrencyInfo(code: 'TRY', symbol: '₺', nameJa: 'トルコ・リラ');
const _rub = CurrencyInfo(code: 'RUB', symbol: '₽', nameJa: 'ロシア・ルーブル');
const _uah = CurrencyInfo(code: 'UAH', symbol: '₴', nameJa: 'ウクライナ・フリヴニャ');
const _brl = CurrencyInfo(code: 'BRL', symbol: r'R$', nameJa: 'ブラジル・レアル');
const _mxn = CurrencyInfo(code: 'MXN', symbol: r'Mex$', nameJa: 'メキシコ・ペソ');
const _zar = CurrencyInfo(code: 'ZAR', symbol: 'R', nameJa: '南アフリカ・ランド');
const _aed = CurrencyInfo(code: 'AED', symbol: 'AED', nameJa: 'UAEディルハム');
const _sar = CurrencyInfo(code: 'SAR', symbol: 'SAR', nameJa: 'サウジ・リヤル');
const _ils = CurrencyInfo(code: 'ILS', symbol: '₪', nameJa: 'イスラエル・シェケル');
const _egp = CurrencyInfo(code: 'EGP', symbol: 'E£', nameJa: 'エジプト・ポンド');
const _xaf = CurrencyInfo(code: 'XAF', symbol: 'FCFA', nameJa: '中部アフリカCFAフラン');
const _xof = CurrencyInfo(code: 'XOF', symbol: 'F CFA', nameJa: '西アフリカCFAフラン');
const _xpf = CurrencyInfo(code: 'XPF', symbol: 'F CFP', nameJa: 'CFPフラン');
const _xcd = CurrencyInfo(code: 'XCD', symbol: r'EC$', nameJa: '東カリブ・ドル');
const _xcg = CurrencyInfo(code: 'XCG', symbol: 'Cg', nameJa: 'カリブ・ギルダー');

/// 国コード（ISO 3166-1 alpha-2）から、その国の主通貨。
///
/// 2026-09 時点の法定の主通貨だけを載せる。
/// 複数の通貨が流通する国（カンボジアの米ドル併用など）も、法定の主通貨を1つにしている。
/// 表に無い国・地域は推測せず、画面では「不明」と出す。
///
/// 例外:
/// - ブルガリア（BG）は 2026-01-01 からユーロ。
/// - キュラソー（CW）とシント・マールテン（SX）は 2025-03-31 からカリブ・ギルダー（XCG）。
const countryCurrencyTable = <String, CurrencyInfo>{
  'AD': _eur,
  'AE': _aed,
  'AF': CurrencyInfo(code: 'AFN', symbol: 'AFN', nameJa: 'アフガニ'),
  'AG': _xcd,
  'AI': _xcd,
  'AL': CurrencyInfo(code: 'ALL', symbol: 'L', nameJa: 'アルバニア・レク'),
  'AM': CurrencyInfo(code: 'AMD', symbol: '֏', nameJa: 'アルメニア・ドラム'),
  'AO': CurrencyInfo(code: 'AOA', symbol: 'Kz', nameJa: 'アンゴラ・クワンザ'),
  'AR': CurrencyInfo(code: 'ARS', symbol: r'$', nameJa: 'アルゼンチン・ペソ'),
  'AS': _usd,
  'AT': _eur,
  'AU': _aud,
  'AW': CurrencyInfo(code: 'AWG', symbol: 'ƒ', nameJa: 'アルバ・フロリン'),
  'AX': _eur,
  'AZ': CurrencyInfo(code: 'AZN', symbol: '₼', nameJa: 'アゼルバイジャン・マナト'),
  'BA': CurrencyInfo(code: 'BAM', symbol: 'KM', nameJa: '兌換マルク'),
  'BB': CurrencyInfo(code: 'BBD', symbol: r'Bds$', nameJa: 'バルバドス・ドル'),
  'BD': CurrencyInfo(code: 'BDT', symbol: '৳', nameJa: 'バングラデシュ・タカ'),
  'BE': _eur,
  'BF': _xof,
  'BG': _eur,
  'BH': CurrencyInfo(code: 'BHD', symbol: 'BHD', nameJa: 'バーレーン・ディナール'),
  'BI': CurrencyInfo(code: 'BIF', symbol: 'FBu', nameJa: 'ブルンジ・フラン'),
  'BJ': _xof,
  'BL': _eur,
  'BM': CurrencyInfo(code: 'BMD', symbol: r'BD$', nameJa: 'バミューダ・ドル'),
  'BN': CurrencyInfo(code: 'BND', symbol: r'B$', nameJa: 'ブルネイ・ドル'),
  'BO': CurrencyInfo(code: 'BOB', symbol: 'Bs', nameJa: 'ボリビアーノ'),
  'BQ': _usd,
  'BR': _brl,
  'BS': CurrencyInfo(code: 'BSD', symbol: r'B$', nameJa: 'バハマ・ドル'),
  'BT': CurrencyInfo(code: 'BTN', symbol: 'Nu.', nameJa: 'ブータン・ニュルタム'),
  'BW': CurrencyInfo(code: 'BWP', symbol: 'P', nameJa: 'ボツワナ・プラ'),
  'BY': CurrencyInfo(code: 'BYN', symbol: 'Br', nameJa: 'ベラルーシ・ルーブル'),
  'BZ': CurrencyInfo(code: 'BZD', symbol: r'BZ$', nameJa: 'ベリーズ・ドル'),
  'CA': _cad,
  'CC': _aud,
  'CD': CurrencyInfo(code: 'CDF', symbol: 'FC', nameJa: 'コンゴ・フラン'),
  'CF': _xaf,
  'CG': _xaf,
  'CH': _chf,
  'CI': _xof,
  'CK': _nzd,
  'CL': CurrencyInfo(code: 'CLP', symbol: r'$', nameJa: 'チリ・ペソ'),
  'CM': _xaf,
  'CN': _cny,
  'CO': CurrencyInfo(code: 'COP', symbol: r'$', nameJa: 'コロンビア・ペソ'),
  'CR': CurrencyInfo(code: 'CRC', symbol: '₡', nameJa: 'コスタリカ・コロン'),
  'CU': CurrencyInfo(code: 'CUP', symbol: r'$', nameJa: 'キューバ・ペソ'),
  'CV': CurrencyInfo(code: 'CVE', symbol: r'$', nameJa: 'カーボベルデ・エスクード'),
  'CW': _xcg,
  'CX': _aud,
  'CY': _eur,
  'CZ': _czk,
  'DE': _eur,
  'DJ': CurrencyInfo(code: 'DJF', symbol: 'Fdj', nameJa: 'ジブチ・フラン'),
  'DK': _dkk,
  'DM': _xcd,
  'DO': CurrencyInfo(code: 'DOP', symbol: r'RD$', nameJa: 'ドミニカ・ペソ'),
  'DZ': CurrencyInfo(code: 'DZD', symbol: 'DZD', nameJa: 'アルジェリア・ディナール'),
  'EC': _usd,
  'EE': _eur,
  'EG': _egp,
  'ER': CurrencyInfo(code: 'ERN', symbol: 'Nfk', nameJa: 'エリトリア・ナクファ'),
  'ES': _eur,
  'ET': CurrencyInfo(code: 'ETB', symbol: 'Br', nameJa: 'エチオピア・ブル'),
  'FI': _eur,
  'FJ': CurrencyInfo(code: 'FJD', symbol: r'FJ$', nameJa: 'フィジー・ドル'),
  'FK': CurrencyInfo(code: 'FKP', symbol: '£', nameJa: 'フォークランド・ポンド'),
  'FM': _usd,
  'FO': _dkk,
  'FR': _eur,
  'GA': _xaf,
  'GB': _gbp,
  'GD': _xcd,
  'GE': CurrencyInfo(code: 'GEL', symbol: '₾', nameJa: 'ジョージア・ラリ'),
  'GF': _eur,
  'GG': _gbp,
  'GH': CurrencyInfo(code: 'GHS', symbol: '₵', nameJa: 'ガーナ・セディ'),
  'GI': CurrencyInfo(code: 'GIP', symbol: '£', nameJa: 'ジブラルタル・ポンド'),
  'GL': _dkk,
  'GM': CurrencyInfo(code: 'GMD', symbol: 'D', nameJa: 'ガンビア・ダラシ'),
  'GN': CurrencyInfo(code: 'GNF', symbol: 'FG', nameJa: 'ギニア・フラン'),
  'GP': _eur,
  'GQ': _xaf,
  'GR': _eur,
  'GT': CurrencyInfo(code: 'GTQ', symbol: 'Q', nameJa: 'グアテマラ・ケツァル'),
  'GU': _usd,
  'GW': _xof,
  'GY': CurrencyInfo(code: 'GYD', symbol: r'G$', nameJa: 'ガイアナ・ドル'),
  'HK': _hkd,
  'HN': CurrencyInfo(code: 'HNL', symbol: 'L', nameJa: 'ホンジュラス・レンピラ'),
  'HR': _eur,
  'HT': CurrencyInfo(code: 'HTG', symbol: 'G', nameJa: 'ハイチ・グールド'),
  'HU': _huf,
  'ID': _idr,
  'IE': _eur,
  'IL': _ils,
  'IM': _gbp,
  'IN': _inr,
  'IQ': CurrencyInfo(code: 'IQD', symbol: 'IQD', nameJa: 'イラク・ディナール'),
  'IR': CurrencyInfo(code: 'IRR', symbol: 'IRR', nameJa: 'イラン・リヤル'),
  'IS': CurrencyInfo(code: 'ISK', symbol: 'kr', nameJa: 'アイスランド・クローナ'),
  'IT': _eur,
  'JE': _gbp,
  'JM': CurrencyInfo(code: 'JMD', symbol: r'J$', nameJa: 'ジャマイカ・ドル'),
  'JO': CurrencyInfo(code: 'JOD', symbol: 'JOD', nameJa: 'ヨルダン・ディナール'),
  'JP': _jpy,
  'KE': CurrencyInfo(code: 'KES', symbol: 'KSh', nameJa: 'ケニア・シリング'),
  'KG': CurrencyInfo(code: 'KGS', symbol: 'сом', nameJa: 'キルギス・ソム'),
  'KH': CurrencyInfo(code: 'KHR', symbol: '៛', nameJa: 'カンボジア・リエル'),
  'KI': _aud,
  'KM': CurrencyInfo(code: 'KMF', symbol: 'CF', nameJa: 'コモロ・フラン'),
  'KN': _xcd,
  'KP': CurrencyInfo(code: 'KPW', symbol: '₩', nameJa: '北朝鮮ウォン'),
  'KR': _krw,
  'KW': CurrencyInfo(code: 'KWD', symbol: 'KWD', nameJa: 'クウェート・ディナール'),
  'KY': CurrencyInfo(code: 'KYD', symbol: r'CI$', nameJa: 'ケイマン・ドル'),
  'KZ': CurrencyInfo(code: 'KZT', symbol: '₸', nameJa: 'カザフスタン・テンゲ'),
  'LA': CurrencyInfo(code: 'LAK', symbol: '₭', nameJa: 'ラオス・キープ'),
  'LB': CurrencyInfo(code: 'LBP', symbol: 'LBP', nameJa: 'レバノン・ポンド'),
  'LC': _xcd,
  'LI': _chf,
  'LK': CurrencyInfo(code: 'LKR', symbol: 'Rs', nameJa: 'スリランカ・ルピー'),
  'LR': CurrencyInfo(code: 'LRD', symbol: r'L$', nameJa: 'リベリア・ドル'),
  'LS': CurrencyInfo(code: 'LSL', symbol: 'L', nameJa: 'レソト・ロチ'),
  'LT': _eur,
  'LU': _eur,
  'LV': _eur,
  'LY': CurrencyInfo(code: 'LYD', symbol: 'LYD', nameJa: 'リビア・ディナール'),
  'MA': CurrencyInfo(code: 'MAD', symbol: 'MAD', nameJa: 'モロッコ・ディルハム'),
  'MC': _eur,
  'MD': CurrencyInfo(code: 'MDL', symbol: 'L', nameJa: 'モルドバ・レウ'),
  'ME': _eur,
  'MF': _eur,
  'MG': CurrencyInfo(code: 'MGA', symbol: 'Ar', nameJa: 'マダガスカル・アリアリ'),
  'MH': _usd,
  'MK': CurrencyInfo(code: 'MKD', symbol: 'ден', nameJa: 'マケドニア・デナール'),
  'ML': _xof,
  'MM': CurrencyInfo(code: 'MMK', symbol: 'K', nameJa: 'ミャンマー・チャット'),
  'MN': CurrencyInfo(code: 'MNT', symbol: '₮', nameJa: 'モンゴル・トゥグルグ'),
  'MO': _mop,
  'MP': _usd,
  'MQ': _eur,
  'MR': CurrencyInfo(code: 'MRU', symbol: 'UM', nameJa: 'モーリタニア・ウギア'),
  'MS': _xcd,
  'MT': _eur,
  'MU': CurrencyInfo(code: 'MUR', symbol: '₨', nameJa: 'モーリシャス・ルピー'),
  'MV': CurrencyInfo(code: 'MVR', symbol: 'Rf', nameJa: 'モルディブ・ルフィア'),
  'MW': CurrencyInfo(code: 'MWK', symbol: 'MK', nameJa: 'マラウイ・クワチャ'),
  'MX': _mxn,
  'MY': _myr,
  'MZ': CurrencyInfo(code: 'MZN', symbol: 'MT', nameJa: 'モザンビーク・メティカル'),
  'NA': CurrencyInfo(code: 'NAD', symbol: r'N$', nameJa: 'ナミビア・ドル'),
  'NC': _xpf,
  'NE': _xof,
  'NF': _aud,
  'NG': CurrencyInfo(code: 'NGN', symbol: '₦', nameJa: 'ナイジェリア・ナイラ'),
  'NI': CurrencyInfo(code: 'NIO', symbol: r'C$', nameJa: 'ニカラグア・コルドバ'),
  'NL': _eur,
  'NO': _nok,
  'NP': CurrencyInfo(code: 'NPR', symbol: 'Rs', nameJa: 'ネパール・ルピー'),
  'NR': _aud,
  'NU': _nzd,
  'NZ': _nzd,
  'OM': CurrencyInfo(code: 'OMR', symbol: 'OMR', nameJa: 'オマーン・リアル'),
  'PA': CurrencyInfo(code: 'PAB', symbol: 'B/.', nameJa: 'パナマ・バルボア'),
  'PE': CurrencyInfo(code: 'PEN', symbol: 'S/', nameJa: 'ペルー・ソル'),
  'PF': _xpf,
  'PG': CurrencyInfo(code: 'PGK', symbol: 'K', nameJa: 'パプアニューギニア・キナ'),
  'PH': _php,
  'PK': CurrencyInfo(code: 'PKR', symbol: '₨', nameJa: 'パキスタン・ルピー'),
  'PL': _pln,
  'PM': _eur,
  'PR': _usd,
  'PS': _ils,
  'PT': _eur,
  'PW': _usd,
  'PY': CurrencyInfo(code: 'PYG', symbol: '₲', nameJa: 'パラグアイ・グアラニー'),
  'QA': CurrencyInfo(code: 'QAR', symbol: 'QAR', nameJa: 'カタール・リヤル'),
  'RE': _eur,
  'RO': _ron,
  'RS': CurrencyInfo(code: 'RSD', symbol: 'дин', nameJa: 'セルビア・ディナール'),
  'RU': _rub,
  'RW': CurrencyInfo(code: 'RWF', symbol: 'FRw', nameJa: 'ルワンダ・フラン'),
  'SA': _sar,
  'SB': CurrencyInfo(code: 'SBD', symbol: r'SI$', nameJa: 'ソロモン諸島ドル'),
  'SC': CurrencyInfo(code: 'SCR', symbol: '₨', nameJa: 'セーシェル・ルピー'),
  'SD': CurrencyInfo(code: 'SDG', symbol: 'SDG', nameJa: 'スーダン・ポンド'),
  'SE': _sek,
  'SG': _sgd,
  'SH': CurrencyInfo(code: 'SHP', symbol: '£', nameJa: 'セントヘレナ・ポンド'),
  'SI': _eur,
  'SK': _eur,
  'SL': CurrencyInfo(code: 'SLE', symbol: 'Le', nameJa: 'シエラレオネ・レオン'),
  'SM': _eur,
  'SN': _xof,
  'SO': CurrencyInfo(code: 'SOS', symbol: 'Sh', nameJa: 'ソマリア・シリング'),
  'SR': CurrencyInfo(code: 'SRD', symbol: r'$', nameJa: 'スリナム・ドル'),
  'SS': CurrencyInfo(code: 'SSP', symbol: 'SSP', nameJa: '南スーダン・ポンド'),
  'ST': CurrencyInfo(code: 'STN', symbol: 'Db', nameJa: 'サントメ・ドブラ'),
  'SV': _usd,
  'SX': _xcg,
  'SZ': CurrencyInfo(code: 'SZL', symbol: 'L', nameJa: 'スワジ・リランゲニ'),
  'TC': _usd,
  'TD': _xaf,
  'TG': _xof,
  'TH': _thb,
  'TJ': CurrencyInfo(code: 'TJS', symbol: 'SM', nameJa: 'タジキスタン・ソモニ'),
  'TL': _usd,
  'TM': CurrencyInfo(code: 'TMT', symbol: 'm', nameJa: 'トルクメニスタン・マナト'),
  'TN': CurrencyInfo(code: 'TND', symbol: 'TND', nameJa: 'チュニジア・ディナール'),
  'TO': CurrencyInfo(code: 'TOP', symbol: r'T$', nameJa: 'トンガ・パアンガ'),
  'TR': _try,
  'TT': CurrencyInfo(code: 'TTD', symbol: r'TT$', nameJa: 'トリニダード・トバゴ・ドル'),
  'TV': _aud,
  'TW': _twd,
  'TZ': CurrencyInfo(code: 'TZS', symbol: 'TSh', nameJa: 'タンザニア・シリング'),
  'UA': _uah,
  'UG': CurrencyInfo(code: 'UGX', symbol: 'USh', nameJa: 'ウガンダ・シリング'),
  'US': _usd,
  'UY': CurrencyInfo(code: 'UYU', symbol: r'$U', nameJa: 'ウルグアイ・ペソ'),
  'UZ': CurrencyInfo(code: 'UZS', symbol: 'soʻm', nameJa: 'ウズベキスタン・スム'),
  'VA': _eur,
  'VC': _xcd,
  'VE': CurrencyInfo(code: 'VES', symbol: 'Bs.S', nameJa: 'ボリバル・ソベラノ'),
  'VG': _usd,
  'VI': _usd,
  'VN': _vnd,
  'VU': CurrencyInfo(code: 'VUV', symbol: 'Vt', nameJa: 'バヌアツ・バツ'),
  'WF': _xpf,
  'WS': CurrencyInfo(code: 'WST', symbol: r'WS$', nameJa: 'サモア・タラ'),
  'XK': _eur,
  'YE': CurrencyInfo(code: 'YER', symbol: 'YER', nameJa: 'イエメン・リアル'),
  'YT': _eur,
  'ZA': _zar,
  'ZM': CurrencyInfo(code: 'ZMW', symbol: 'ZK', nameJa: 'ザンビア・クワチャ'),
  'ZW': CurrencyInfo(code: 'ZWG', symbol: 'ZiG', nameJa: 'ジンバブエ・ゴールド'),
};
