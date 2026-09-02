import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';
import '../models/chore_task.dart';
import '../models/task_execution.dart';
import '../utils/jst_date.dart';
import '../utils/remaining_days.dart';

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ChoreTask>> watchActive(String householdId) {
    return _firestore
        .collection(FirestorePaths.tasks(householdId))
        .snapshots()
        .map((snap) {
      final tasks = snap.docs
          .map(ChoreTask.fromDoc)
          .where((task) => !task.archived)
          .toList();
      final today = JstDate.today();
      tasks.sort((a, b) {
        final byDue = a.remainingDaysOn(today).compareTo(b.remainingDaysOn(today));
        if (byDue != 0) {
          return byDue;
        }
        return a.title.compareTo(b.title);
      });
      return tasks;
    });
  }

  /// 未実行のタスクは「今日が期限」。
  Future<void> addTask({
    required String householdId,
    required String uid,
    required String title,
    required int intervalDays,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw StateError('タスク名を入力してください');
    }
    if (intervalDays < 1) {
      throw StateError('間隔は 1 日以上にしてください');
    }

    final today = JstDate.today();
    await _firestore.collection(FirestorePaths.tasks(householdId)).add({
      ChoreTaskFields.title: trimmed,
      ChoreTaskFields.intervalDays: intervalDays,
      ChoreTaskFields.nextDueOn: JstDate.format(today),
      ChoreTaskFields.createdAt: Timestamp.now(),
      ChoreTaskFields.createdBy: uid,
      ChoreTaskFields.lastExecutedAt: null,
      ChoreTaskFields.lastExecutedBy: null,
      ChoreTaskFields.archived: false,
    });
  }

  Future<void> completeTask({
    required String householdId,
    required ChoreTask task,
    required String uid,
  }) async {
    final today = JstDate.today();
    final nextDueOn = nextDueOnAfterCompletion(
      intervalDays: task.intervalDays,
      completedOnJst: today,
    );
    final now = Timestamp.now();

    final taskRef = _firestore.doc(FirestorePaths.task(householdId, task.id));
    final execRef = _firestore
        .collection(FirestorePaths.executions(householdId, task.id))
        .doc();

    final batch = _firestore.batch();
    batch.update(taskRef, {
      ChoreTaskFields.lastExecutedAt: now,
      ChoreTaskFields.lastExecutedBy: uid,
      ChoreTaskFields.nextDueOn: nextDueOn,
    });
    batch.set(execRef, {
      'executedAt': now,
      'executedBy': uid,
    });
    await batch.commit();
  }

  Future<void> archiveTask({
    required String householdId,
    required String taskId,
  }) {
    return _firestore.doc(FirestorePaths.task(householdId, taskId)).update({
      ChoreTaskFields.archived: true,
    });
  }

  Future<List<TaskExecution>> fetchRecentExecutions({
    required String householdId,
    required String taskId,
    int limit = 50,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.executions(householdId, taskId))
        .orderBy(TaskExecutionFields.executedAt, descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(TaskExecution.fromDoc).toList();
  }
}
