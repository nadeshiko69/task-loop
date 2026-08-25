import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class AppUserFields {
  static const displayName = 'displayName';
  static const householdId = 'householdId';
  static const createdAt = 'createdAt';
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.householdId,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String? householdId;
  final DateTime createdAt;

  bool get hasHousehold => householdId != null && householdId!.isNotEmpty;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      displayName: data[AppUserFields.displayName] as String? ?? 'メンバー',
      householdId: data[AppUserFields.householdId] as String?,
      createdAt: _readTime(data[AppUserFields.createdAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppUserFields.displayName: displayName,
      AppUserFields.householdId: householdId,
      AppUserFields.createdAt: Timestamp.fromDate(createdAt),
    };
  }
}

DateTime _readTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now().toUtc();
}
