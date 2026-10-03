import 'dart:convert';

import 'package:map_rate/features/currency/currency_info.dart';
import 'package:map_rate/features/currency/exchange_rate_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 為替レートと、リストの順番・固定国を端末に残す。
class ExchangePrefs {
  static const _ratesKey = 'maprate_rates_v1';
  static const _orderKey = 'maprate_order_v1';
  static const _pinnedKey = 'maprate_pinned_v1';
  static const _baseCountryKey = 'maprate_base_country_v1';
  static const _baseAmountKey = 'maprate_base_amount_v1';

  Future<void> saveSnapshot(ExchangeRateSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    // 履歴は直近14点までに抑えて、端末の保存サイズを小さくする
    final compactHistory = <String, List<double>>{};
    for (final entry in snapshot.historyPerUsd.entries) {
      final values = entry.value;
      if (values.isEmpty) continue;
      compactHistory[entry.key] = values.length <= 14
          ? List<double>.from(values)
          : values.sublist(values.length - 14);
    }
    final payload = <String, Object?>{
      'rateDate': snapshot.rateDate,
      'fetchedAt': snapshot.fetchedAt.toIso8601String(),
      'sourceName': snapshot.sourceName,
      'isOfflineSeed': snapshot.isOfflineSeed,
      'ratesPerUsd': snapshot.ratesPerUsd,
      'historyPerUsd': compactHistory,
    };
    await prefs.setString(_ratesKey, jsonEncode(payload));
  }

  Future<ExchangeRateSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ratesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final ratesRaw = decoded['ratesPerUsd'];
      final historyRaw = decoded['historyPerUsd'];
      if (ratesRaw is! Map || historyRaw is! Map) return null;

      final rates = <String, double>{};
      for (final entry in ratesRaw.entries) {
        final key = entry.key.toString().toUpperCase();
        final value = entry.value;
        if (!RegExp(r'^[A-Z]{3}$').hasMatch(key)) continue;
        if (value is! num || !value.isFinite || value <= 0) continue;
        rates[key] = value.toDouble();
      }
      rates.putIfAbsent('USD', () => 1.0);

      final history = <String, List<double>>{};
      for (final entry in historyRaw.entries) {
        final key = entry.key.toString().toUpperCase();
        if (!RegExp(r'^[A-Z]{3}$').hasMatch(key)) continue;
        final list = entry.value;
        if (list is! List) continue;
        final values = <double>[];
        for (final item in list) {
          if (item is num && item.isFinite && item > 0) {
            values.add(item.toDouble());
          }
        }
        if (values.isNotEmpty) history[key] = values;
      }

      final rateDate = decoded['rateDate']?.toString() ?? '';
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rateDate)) return null;
      final fetchedAtRaw = decoded['fetchedAt']?.toString();
      final fetchedAt = DateTime.tryParse(fetchedAtRaw ?? '');
      if (fetchedAt == null) return null;
      final sourceName = decoded['sourceName']?.toString() ?? 'Frankfurter';

      return ExchangeRateSnapshot(
        ratesPerUsd: Map.unmodifiable(rates),
        historyPerUsd: Map.unmodifiable(history),
        rateDate: rateDate,
        fetchedAt: fetchedAt.toUtc(),
        sourceName: sourceName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return _sanitizeCountryList(prefs.getStringList(_orderKey) ?? const []);
  }

  Future<void> saveOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, _sanitizeCountryList(order));
  }

  Future<List<String>> loadPinned() async {
    final prefs = await SharedPreferences.getInstance();
    return _sanitizeCountryList(prefs.getStringList(_pinnedKey) ?? const []);
  }

  Future<void> savePinned(List<String> pinned) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedKey, _sanitizeCountryList(pinned));
  }

  Future<String?> loadBaseCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return normalizeCountryCode(prefs.getString(_baseCountryKey));
  }

  Future<void> saveBaseCountry(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = normalizeCountryCode(code);
    if (normalized == null) {
      await prefs.remove(_baseCountryKey);
      return;
    }
    await prefs.setString(_baseCountryKey, normalized);
  }

  Future<double> loadBaseAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_baseAmountKey);
    if (value == null || !value.isFinite || value < 0) return 100;
    // 極端な値は拒否して初期値に戻す
    if (value > 1e12) return 100;
    return value;
  }

  Future<void> saveBaseAmount(double amount) async {
    if (!amount.isFinite || amount < 0 || amount > 1e12) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_baseAmountKey, amount);
  }

  List<String> _sanitizeCountryList(List<String> raw) {
    final out = <String>[];
    final seen = <String>{};
    for (final item in raw) {
      final code = normalizeCountryCode(item);
      if (code == null || seen.contains(code)) continue;
      if (currencyForCountryCode(code) == null) continue;
      seen.add(code);
      out.add(code);
    }
    return out;
  }
}
