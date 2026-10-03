// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'MapRate';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get centerCurrencyTitle => 'Mata uang di pusat peta';

  @override
  String get resolving => 'Mencari…';

  @override
  String get moveMapHint =>
      'Gerakkan peta untuk mendeteksi negara dan mata uang di pusat.';

  @override
  String countryCodeLabel(String code) {
    return 'Kode negara $code';
  }

  @override
  String countryWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String currencyLine(String label) {
    return 'Mata uang $label';
  }

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get invalidCoordinates => 'Lintang atau bujur tidak valid';

  @override
  String get geocoderUnavailable => 'Perangkat ini tidak dapat mencari negara';

  @override
  String get countryNotFound =>
      'Tidak dapat mengidentifikasi negara di lokasi ini';

  @override
  String get countryLookupFailed =>
      'Tidak dapat mengambil info negara. Periksa koneksi.';

  @override
  String get exchangeListTitle => 'Kurs di peta';

  @override
  String updatedAt(String time) {
    return 'Diperbarui: $time';
  }

  @override
  String rateDate(String date) {
    return 'Tanggal kurs: $date';
  }

  @override
  String get notUpdatedYet => 'Belum diperbarui';

  @override
  String get dataSourceTitle => 'Tentang data kurs';

  @override
  String get dataSourceBody =>
      'MapRate memuat kurs mid-market dari ExchangeRate-API (open.er-api.com), lalu feed CDN, lalu Frankfurter. Jumlah dikonversi via USD. Grafik sparkline memakai riwayat Frankfurter jika tersedia. Kurs indikatif, bukan kuotasi trading.';

  @override
  String get pinCountry => 'Sematkan';

  @override
  String get unpinCountry => 'Lepas sematan';

  @override
  String get reorderHint => 'Seret pegangan untuk mengurutkan';

  @override
  String get loadingRates => 'Memuat kurs…';

  @override
  String get ratesLoadFailed =>
      'Kurs live gagal dimuat. Menampilkan data seed bawaan.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get offlineSeedHint => 'Kurs seed offline';

  @override
  String get rateUnavailable => 'T/A';

  @override
  String get noCountriesOnMap =>
      'Tidak ada mata uang terlihat. Geser peta atau sematkan negara.';

  @override
  String get amountHint => 'Jumlah';

  @override
  String get close => 'Tutup';

  @override
  String get aboutTitle => 'Tentang MapRate';

  @override
  String get aboutBody =>
      'MapRate menghubungkan peta dunia dengan kurs live. Gerakkan peta untuk melihat mata uang di pusat, konversi jumlah, dan sematkan negara untuk membandingkan.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get showTrendChart => 'Tampilkan grafik tren';

  @override
  String get trendChartTitle => 'Tren kurs';

  @override
  String get myLocationTooltip => 'Ke lokasi saya';

  @override
  String get locationPermissionDenied => 'Izin lokasi ditolak';

  @override
  String get locationServiceDisabled =>
      'Nyalakan layanan lokasi untuk fitur ini';

  @override
  String get locationFailed => 'Tidak dapat mendapatkan lokasi Anda';

  @override
  String get menuAbout => 'Tentang';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get adLoading => 'Memuat iklan…';

  @override
  String get trendAxisUnit => 'Tanggal (hari)';

  @override
  String trendYAxisUnit(String currency) {
    return '$currency per 1 USD';
  }

  @override
  String get baseInputLabel => 'Diinput';

  @override
  String get updateAvailableTitle => 'Pembaruan tersedia';

  @override
  String updateAvailableBody(String version) {
    return 'Versi $version tersedia. Silakan perbarui.';
  }

  @override
  String get updateNow => 'Perbarui';

  @override
  String get updateLater => 'Nanti';

  @override
  String get updateOpenFailed => 'Tidak bisa membuka toko';

  @override
  String appVersionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get checkForUpdate => 'Periksa pembaruan';

  @override
  String get updateUpToDate => 'Anda memakai versi terbaru';

  @override
  String get updateCheckFailed => 'Tidak bisa memeriksa pembaruan';

  @override
  String get hideExchangeList => 'Sembunyikan kurs';

  @override
  String get showExchangeList => 'Tampilkan kurs';
}
