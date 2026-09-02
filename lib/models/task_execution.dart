import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class TaskExecutionFields {
  static const executedAt = 'executedAt';
  static const executedBy = 'executedBy';
}

class TaskExecution {
  const TaskExecution({
    required this.id,
    required this.executedAt,
    required this.executedBy,
  });

  final String id;
  final DateTime executedAt;
  final String executedBy;

  factory TaskExecution.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskExecution(
      id: doc.id,
      executedAt: _readTime(data[TaskExecutionFields.executedAt]),
      executedBy: data[TaskExecutionFields.executedBy] as String? ?? '',
    );
  }
}

DateTime _readTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now().toUtc();
}
