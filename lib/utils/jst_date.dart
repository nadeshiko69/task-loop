/// 日本時間（UTC+9）の「日付だけ」を扱う。
///
/// Firestore の Timestamp は UTC なので、期限判定は必ずここを通す。
/// 端末のタイムゾーンに引きずられないよう、日付は UTC 上の Y-M-D として持つ。
class JstDate {
  static const Duration offset = Duration(hours: 9);

  /// いまの日本時間の日付（時刻は 00:00、UTC として保持）
  static DateTime today({DateTime? nowUtc}) {
    final utc = nowUtc ?? DateTime.now().toUtc();
    final jst = utc.add(offset);
    return DateTime.utc(jst.year, jst.month, jst.day);
  }

  /// `2026-08-31` 形式
  static String format(DateTime utcDateOnly) {
    final year = utcDateOnly.year.toString().padLeft(4, '0');
    final month = utcDateOnly.month.toString().padLeft(2, '0');
    final day = utcDateOnly.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime parse(String stamp) {
    final parts = stamp.split('-');
    if (parts.length != 3) {
      throw FormatException('日付は YYYY-MM-DD 形式です', stamp);
    }
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static DateTime addDays(DateTime utcDateOnly, int days) {
    return utcDateOnly.add(Duration(days: days));
  }

  /// [to] - [from] の日数。同じ日なら 0。
  static int daysBetween({required DateTime from, required DateTime to}) {
    return to.difference(from).inDays;
  }

  /// 日本時間で `YYYY/MM/DD HH:mm` 形式にする。
  static String formatDateTime(DateTime dateTime) {
    final jst = dateTime.toUtc().add(offset);
    final year = jst.year.toString().padLeft(4, '0');
    final month = jst.month.toString().padLeft(2, '0');
    final day = jst.day.toString().padLeft(2, '0');
    final hour = jst.hour.toString().padLeft(2, '0');
    final minute = jst.minute.toString().padLeft(2, '0');
    return '$year/$month/$day $hour:$minute';
  }
}
