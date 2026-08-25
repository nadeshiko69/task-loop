/// Firestore のパスを一箇所に集める。
/// 画面や Repository で文字列を直書きしない。
class FirestorePaths {
  static const users = 'users';
  static String user(String uid) => '$users/$uid';

  static const households = 'households';
  static String household(String id) => '$households/$id';

  static String members(String householdId) =>
      '$households/$householdId/members';
  static String member(String householdId, String uid) =>
      '${members(householdId)}/$uid';

  static String tasks(String householdId) => '$households/$householdId/tasks';
  static String task(String householdId, String taskId) =>
      '${tasks(householdId)}/$taskId';

  static String executions(String householdId, String taskId) =>
      '${task(householdId, taskId)}/executions';

  static const invites = 'invites';
  static String invite(String code) => '$invites/$code';
}
