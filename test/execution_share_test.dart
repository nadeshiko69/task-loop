import 'package:flutter_test/flutter_test.dart';
import 'package:task_loop/utils/execution_share.dart';

void main() {
  test('履歴が空なら割合は出さない', () {
    final summary = summarizeExecutionShares(const []);

    expect(summary.sampleCount, 0);
    expect(summary.shares, isEmpty);
  });

  test('直近10回を回数の多い順にパーセント化する', () {
    final summary = summarizeExecutionShares([
      'a',
      'a',
      'b',
      'a',
      'c',
      'b',
      'a',
      'c',
      'b',
      'a',
      'ignored',
    ]);

    expect(summary.sampleCount, 10);
    expect(
      summary.shares.map((share) => (share.executedBy, share.count, share.percent)),
      [
        ('a', 5, 50),
        ('b', 3, 30),
        ('c', 2, 20),
      ],
    );
    expect(
      summary.shares.fold<int>(0, (sum, share) => sum + share.percent),
      100,
    );
  });

  test('10回未満なら実在する回数だけで割合を出す', () {
    final summary = summarizeExecutionShares(['a', 'b', 'a']);

    expect(summary.sampleCount, 3);
    expect(summary.shares.map((share) => share.executedBy), ['a', 'b']);
    expect(summary.shares.map((share) => share.percent), [67, 33]);
  });

  test('3等分の端数は uid 順に配り、合計は 100 になる', () {
    final summary = summarizeExecutionShares(['c', 'a', 'b']);

    expect(summary.shares.map((share) => (share.executedBy, share.percent)), [
      ('a', 34),
      ('b', 33),
      ('c', 33),
    ]);
  });
}
