import 'package:flutter_test/flutter_test.dart';

import 'package:task_loop/app.dart';

void main() {
  testWidgets('Firebase 未設定ならセットアップ画面を出す', (tester) async {
    await tester.pumpWidget(const TaskLApp());
    expect(find.textContaining('Firebase'), findsWidgets);
  });
}
