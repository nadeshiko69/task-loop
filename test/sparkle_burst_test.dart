import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_loop/models/chore_task.dart';
import 'package:task_loop/widgets/chore_task_tile.dart';
import 'package:task_loop/widgets/sparkle_burst.dart';

void main() {
  testWidgets('できたを押すとキラッとしてから完了する', (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChoreTaskTile(
            task: ChoreTask(
              id: 'bath',
              title: 'お風呂',
              intervalDays: 7,
              nextDueOn: '2099-01-01',
              createdAt: DateTime.utc(2026, 1, 1),
              createdBy: 'user',
            ),
            onComplete: () => completed += 1,
            onArchive: () {},
            onShowDetails: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('できた'));
    expect(completed, 1);
    await tester.pump();
    expect(find.byKey(sparkleBurstKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(sparkleBurstKey), findsNothing);
  });
}
