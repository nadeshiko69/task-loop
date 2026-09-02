import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';
import '../models/app_user.dart';
import '../models/household.dart';
import '../utils/invite_code.dart';

class HouseholdRepository {
  HouseholdRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<Household?> watch(String householdId) {
    return _firestore
        .doc(FirestorePaths.household(householdId))
        .snapshots()
        .map((snap) => snap.exists ? Household.fromDoc(snap) : null);
  }

  /// 世帯・自分・招待コードをまとめて作る。
  Future<Household> createHousehold({
    required AppUser user,
    required String name,
  }) async {
    final householdRef = _firestore.collection(FirestorePaths.households).doc();
    final code = await _unusedInviteCode();
    final now = Timestamp.now();

    final batch = _firestore.batch();
    batch.set(householdRef, {
      HouseholdFields.name: name.trim().isEmpty ? '家族' : name.trim(),
      HouseholdFields.timezone: 'Asia/Tokyo',
      HouseholdFields.inviteCode: code,
      HouseholdFields.createdBy: user.uid,
      HouseholdFields.createdAt: now,
    });
    batch.set(
      _firestore.doc(FirestorePaths.member(householdRef.id, user.uid)),
      {
        MemberFields.role: 'owner',
        MemberFields.displayName: user.displayName,
        MemberFields.joinedAt: now,
      },
    );
    batch.set(_firestore.doc(FirestorePaths.invite(code)), {
      'householdId': householdRef.id,
      'createdAt': now,
    });
    batch.update(_firestore.doc(FirestorePaths.user(user.uid)), {
      AppUserFields.householdId: householdRef.id,
    });
    await batch.commit();

    final snap = await householdRef.get();
    return Household.fromDoc(snap);
  }

  Future<void> joinWithCode({
    required AppUser user,
    required String rawCode,
  }) async {
    final code = normalizeInviteCode(rawCode);
    if (code.isEmpty) {
      throw StateError('招待コードを入力してください');
    }

    final inviteSnap =
        await _firestore.doc(FirestorePaths.invite(code)).get();
    if (!inviteSnap.exists) {
      throw StateError('招待コードが見つかりません');
    }

    final householdId = inviteSnap.data()?['householdId'] as String?;
    if (householdId == null || householdId.isEmpty) {
      throw StateError('招待コードが無効です');
    }

    final now = Timestamp.now();
    final batch = _firestore.batch();
    batch.set(
      _firestore.doc(FirestorePaths.member(householdId, user.uid)),
      {
        MemberFields.role: 'member',
        MemberFields.displayName: user.displayName,
        MemberFields.joinedAt: now,
      },
    );
    batch.update(_firestore.doc(FirestorePaths.user(user.uid)), {
      AppUserFields.householdId: householdId,
    });
    await batch.commit();
  }

  Future<Map<String, String>> fetchMemberDisplayNames(String householdId) async {
    final snap =
        await _firestore.collection(FirestorePaths.members(householdId)).get();
    return {
      for (final doc in snap.docs)
        doc.id: HouseholdMember.fromDoc(doc).displayName,
    };
  }

  Future<void> leaveHousehold({
    required String uid,
    required String householdId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.doc(FirestorePaths.member(householdId, uid)));
    batch.update(_firestore.doc(FirestorePaths.user(uid)), {
      AppUserFields.householdId: null,
    });
    await batch.commit();
  }

  Future<String> _unusedInviteCode() async {
    for (var i = 0; i < 8; i++) {
      final code = generateInviteCode();
      final snap = await _firestore.doc(FirestorePaths.invite(code)).get();
      if (!snap.exists) {
        return code;
      }
    }
    throw StateError('招待コードを発行できませんでした。もう一度試してください');
  }
}
