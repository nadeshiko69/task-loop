import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class HouseholdFields {
  static const name = 'name';
  static const timezone = 'timezone';
  static const inviteCode = 'inviteCode';
  static const createdBy = 'createdBy';
  static const createdAt = 'createdAt';
}

abstract final class MemberFields {
  static const role = 'role';
  static const displayName = 'displayName';
  static const joinedAt = 'joinedAt';
}

class Household {
  const Household({
    required this.id,
    required this.name,
    required this.timezone,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String timezone;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;

  factory Household.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Household(
      id: doc.id,
      name: data[HouseholdFields.name] as String? ?? '家族',
      timezone: data[HouseholdFields.timezone] as String? ?? 'Asia/Tokyo',
      inviteCode: data[HouseholdFields.inviteCode] as String? ?? '',
      createdBy: data[HouseholdFields.createdBy] as String? ?? '',
      createdAt: _readTime(data[HouseholdFields.createdAt]),
    );
  }
}

class HouseholdMember {
  const HouseholdMember({
    required this.uid,
    required this.role,
    required this.displayName,
    required this.joinedAt,
  });

  final String uid;
  final String role;
  final String displayName;
  final DateTime joinedAt;

  bool get isOwner => role == 'owner';

  factory HouseholdMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HouseholdMember(
      uid: doc.id,
      role: data[MemberFields.role] as String? ?? 'member',
      displayName: data[MemberFields.displayName] as String? ?? 'メンバー',
      joinedAt: _readTime(data[MemberFields.joinedAt]),
    );
  }
}

DateTime _readTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now().toUtc();
}
