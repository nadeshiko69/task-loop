import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/chore_task.dart';
import '../models/household.dart';
import '../repositories/repositories.dart';
import '../widgets/anchored_banner_ad.dart';
import '../widgets/chore_task_tile.dart';
import '../widgets/error_snackbar.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'task_detail_screen.dart';

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
      rethrow;
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
                  builder:
                      (_) => SettingsScreen(user: user, household: household),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      bottomNavigationBar: const AnchoredBannerAd(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) =>
                      AddTaskScreen(householdId: household.id, uid: user.uid),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('家事を追加'),
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
            return const _EmptyTaskList();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ChoreTaskTile(
                key: ValueKey(task.id),
                task: task,
                onComplete: () => _complete(context, task),
                onArchive: () => _archive(context, task),
                onShowDetails: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => TaskDetailScreen(
                            householdId: household.id,
                            task: task,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  const _EmptyTaskList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_rounded,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text('まだ家事がありません', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '右下の「家事を追加」から、\n家族で共有する家事を登録できます。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
