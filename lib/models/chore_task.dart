import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/remaining_days.dart';

abstract final class ChoreTaskFields {
  static const title = 'title';
  static const intervalDays = 'intervalDays';
  static const lastExecutedAt = 'lastExecutedAt';
  static const lastExecutedBy = 'lastExecutedBy';
  static const nextDueOn = 'nextDueOn';
  static const createdAt = 'createdAt';
  static const createdBy = 'createdBy';
  static const archived = 'archived';
}

/// 家族で共有する家事タスク。
///
/// 期限の正は [lastExecutedAt] + [intervalDays]。
/// [nextDueOn] は一覧を日付順に出すためのキャッシュ（YYYY-MM-DD、JST）。
class ChoreTask {
  const ChoreTask({
    required this.id,
    required this.title,
    required this.intervalDays,
    required this.nextDueOn,
    required this.createdAt,
    required this.createdBy,
    this.lastExecutedAt,
    this.lastExecutedBy,
    this.archived = false,
  });

  final String id;
  final String title;
  final int intervalDays;
  final String nextDueOn;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastExecutedAt;
  final String? lastExecutedBy;
  final bool archived;

  int remainingDaysOn(DateTime todayJst) {
    if (nextDueOn.isEmpty) {
      return 0;
    }
    return remainingDays(nextDueOn: nextDueOn, todayJst: todayJst);
  }

  factory ChoreTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChoreTask(
      id: doc.id,
      title: data[ChoreTaskFields.title] as String? ?? '',
      intervalDays: data[ChoreTaskFields.intervalDays] as int? ?? 7,
      nextDueOn: data[ChoreTaskFields.nextDueOn] as String? ?? '',
      createdAt: _readTime(data[ChoreTaskFields.createdAt]),
      createdBy: data[ChoreTaskFields.createdBy] as String? ?? '',
      lastExecutedAt: _readTimeOrNull(data[ChoreTaskFields.lastExecutedAt]),
      lastExecutedBy: data[ChoreTaskFields.lastExecutedBy] as String?,
      archived: data[ChoreTaskFields.archived] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ChoreTaskFields.title: title,
      ChoreTaskFields.intervalDays: intervalDays,
      ChoreTaskFields.nextDueOn: nextDueOn,
      ChoreTaskFields.createdAt: Timestamp.fromDate(createdAt),
      ChoreTaskFields.createdBy: createdBy,
      ChoreTaskFields.lastExecutedAt: lastExecutedAt == null
          ? null
          : Timestamp.fromDate(lastExecutedAt!),
      ChoreTaskFields.lastExecutedBy: lastExecutedBy,
      ChoreTaskFields.archived: archived,
    };
  }
}

DateTime _readTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now().toUtc();
}

DateTime? _readTimeOrNull(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}
