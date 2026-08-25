import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/chore_task.dart';
import '../models/household.dart';
import '../repositories/repositories.dart';
import '../widgets/chore_task_tile.dart';
import '../widgets/error_snackbar.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    super.key,
    required this.user,
    required this.household,
  });

  final AppUser user;
  final Household household;

  Future<void> _complete(BuildContext context, ChoreTask task) async {
    try {
      await taskRepository.completeTask(
        householdId: household.id,
        task: task,
        uid: user.uid,
      );
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error);
      }
    }
  }

  Future<void> _archive(BuildContext context, ChoreTask task) async {
    try {
      await taskRepository.archiveTask(
        householdId: household.id,
        taskId: task.id,
      );
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(household.name),
        actions: [
          IconButton(
            tooltip: '設定',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    user: user,
                    household: household,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                householdId: household.id,
                uid: user.uid,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('タスクを追加'),
      ),
      body: StreamBuilder<List<ChoreTask>>(
        stream: taskRepository.watchActive(household.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('読み込みに失敗しました\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(
              child: Text('まだタスクがありません。右下から追加できます。'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ChoreTaskTile(
                task: task,
                onComplete: () => _complete(context, task),
                onArchive: () => _archive(context, task),
              );
            },
          );
        },
      ),
    );
  }
}
