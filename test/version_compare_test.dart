import 'package:flutter_test/flutter_test.dart';
import 'package:map_rate/features/update/version_compare.dart';

void main() {
  test('版数比較はセマンティックに行う', () {
    expect(compareVersions('1.0.1', '1.0.0'), greaterThan(0));
    expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
    expect(compareVersions('1.2', '1.2.0'), 0);
    expect(compareVersions('1.10.0', '1.9.9'), greaterThan(0));
    expect(compareVersions('2.0.0+3', '2.0.0+1'), 0);
  });

  test('タイトル用の短い版表示', () {
    expect(formatDisplayVersion('0.0.1'), 'v1');
    expect(formatDisplayVersion('0.0.2'), 'v2');
    expect(formatDisplayVersion('1.0.0'), 'v1');
    expect(formatDisplayVersion('0.3.1'), 'v3');
    expect(formatDisplayVersion('2.4.0+9'), 'v2');
  });
}
