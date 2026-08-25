import 'dart:math';

/// 6桁の数字。0始まりを避けて読みやすくする。
String generateInviteCode({Random? random}) {
  final rng = random ?? Random();
  return (100000 + rng.nextInt(900000)).toString();
}

String normalizeInviteCode(String raw) {
  return raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
}
