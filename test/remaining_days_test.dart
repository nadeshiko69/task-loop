import 'package:flutter_test/flutter_test.dart';

import 'package:task_loop/utils/jst_date.dart';
import 'package:task_loop/utils/remaining_days.dart';

void main() {
  final today = JstDate.parse('2026-08-24');

  test('期限が今日なら 0', () {
    expect(
      remainingDays(nextDueOn: '2026-08-24', todayJst: today),
      0,
    );
    expect(remainingDaysLabel(0), '今日やる');
  });

  test('7日後なら残り7日', () {
    expect(
      remainingDays(nextDueOn: '2026-08-31', todayJst: today),
      7,
    );
    expect(remainingDaysLabel(7), '残り7日');
  });

  test('期限切れは負の日数', () {
    expect(
      remainingDays(nextDueOn: '2026-08-22', todayJst: today),
      -2,
    );
    expect(remainingDaysLabel(-2), '2日遅れ');
  });

  test('今日完了すると、間隔日数後が次の期限', () {
    expect(
      nextDueOnAfterCompletion(intervalDays: 7, completedOnJst: today),
      '2026-08-31',
    );
  });
}
