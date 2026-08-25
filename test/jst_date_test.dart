import 'package:flutter_test/flutter_test.dart';

import 'package:task_loop/utils/jst_date.dart';

void main() {
  group('JstDate.today', () {
    test('UTC 14:59 はまだ日本時間の同じ日', () {
      final utc = DateTime.utc(2026, 8, 24, 14, 59);
      expect(JstDate.format(JstDate.today(nowUtc: utc)), '2026-08-24');
    });

    test('UTC 15:00 は日本時間の翌日 0:00', () {
      final utc = DateTime.utc(2026, 8, 24, 15, 0);
      expect(JstDate.format(JstDate.today(nowUtc: utc)), '2026-08-25');
    });
  });

  group('JstDate.addDays', () {
    test('月末をまたげる', () {
      final start = JstDate.parse('2026-08-31');
      expect(JstDate.format(JstDate.addDays(start, 1)), '2026-09-01');
    });
  });
}
