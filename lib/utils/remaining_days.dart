import 'jst_date.dart';

/// 残り日数 = 次回期限 - 今日
///
/// - 正: まだ先（7 なら「残り7日」）
/// - 0: 今日が期限
/// - 負: 期限切れ（-2 なら 2 日遅れ）
int remainingDays({
  required String nextDueOn,
  required DateTime todayJst,
}) {
  final due = JstDate.parse(nextDueOn);
  return JstDate.daysBetween(from: todayJst, to: due);
}

String remainingDaysLabel(int remaining) {
  if (remaining > 0) {
    return '残り$remaining日';
  }
  if (remaining == 0) {
    return '今日やる';
  }
  return '${remaining.abs()}日遅れ';
}

/// 完了した日を起点に、次の期限を計算する。
/// 例: 間隔 7 日で今日完了 → 7 日後が期限。
String nextDueOnAfterCompletion({
  required int intervalDays,
  required DateTime completedOnJst,
}) {
  return JstDate.format(JstDate.addDays(completedOnJst, intervalDays));
}
