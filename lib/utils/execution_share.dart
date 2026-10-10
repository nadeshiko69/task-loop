/// 実行割合の集計に使う直近回数。
const executionShareSampleSize = 10;

class ExecutionShare {
  const ExecutionShare({
    required this.executedBy,
    required this.count,
    required this.percent,
  });

  final String executedBy;
  final int count;

  /// 0〜100。同一集計内の合計は 100。
  final int percent;
}

class ExecutionShareSummary {
  const ExecutionShareSummary({
    required this.sampleCount,
    required this.shares,
  });

  final int sampleCount;
  final List<ExecutionShare> shares;
}

/// [executedByNewestFirst] の先頭 [sampleSize] 件から、実行者ごとの割合を求める。
///
/// パーセントは整数にし、最大剰余方式で合計が 100 になるようにする。
/// 同数のときは uid の昇順で端数を配る。
ExecutionShareSummary summarizeExecutionShares(
  Iterable<String> executedByNewestFirst, {
  int sampleSize = executionShareSampleSize,
}) {
  if (sampleSize < 1) {
    throw ArgumentError.value(sampleSize, 'sampleSize', '1 以上にしてください');
  }

  final sample = executedByNewestFirst.take(sampleSize).toList();
  if (sample.isEmpty) {
    return const ExecutionShareSummary(sampleCount: 0, shares: []);
  }

  final counts = <String, int>{};
  for (final uid in sample) {
    counts.update(uid, (value) => value + 1, ifAbsent: () => 1);
  }

  final total = sample.length;
  final rows = <_ShareRow>[];
  for (final entry in counts.entries) {
    final scaled = entry.value * 100;
    rows.add(
      _ShareRow(
        executedBy: entry.key,
        count: entry.value,
        percent: scaled ~/ total,
        remainder: scaled % total,
      ),
    );
  }

  var leftover = 100 - rows.fold<int>(0, (sum, row) => sum + row.percent);
  rows.sort((a, b) {
    final byRemainder = b.remainder.compareTo(a.remainder);
    if (byRemainder != 0) {
      return byRemainder;
    }
    return a.executedBy.compareTo(b.executedBy);
  });
  for (var i = 0; i < rows.length && leftover > 0; i++) {
    rows[i] = rows[i].copyWith(percent: rows[i].percent + 1);
    leftover--;
  }

  rows.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    if (byCount != 0) {
      return byCount;
    }
    return a.executedBy.compareTo(b.executedBy);
  });

  return ExecutionShareSummary(
    sampleCount: total,
    shares: [
      for (final row in rows)
        ExecutionShare(
          executedBy: row.executedBy,
          count: row.count,
          percent: row.percent,
        ),
    ],
  );
}

class _ShareRow {
  const _ShareRow({
    required this.executedBy,
    required this.count,
    required this.percent,
    required this.remainder,
  });

  final String executedBy;
  final int count;
  final int percent;
  final int remainder;

  _ShareRow copyWith({required int percent}) {
    return _ShareRow(
      executedBy: executedBy,
      count: count,
      percent: percent,
      remainder: remainder,
    );
  }
}
