import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firestore_paths.dart';
import '../models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.doc(FirestorePaths.user(uid));
  }

  Stream<AppUser?> watch(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists) {
        return null;
      }
      return AppUser.fromDoc(snap);
    });
  }

  Future<AppUser> ensureUser({
    required User authUser,
    String? fullNameFromApple,
  }) async {
    final ref = _doc(authUser.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      final created = AppUser(
        uid: authUser.uid,
        displayName: _pickName(
          fullNameFromApple: fullNameFromApple,
          authUser: authUser,
        ),
        createdAt: DateTime.now().toUtc(),
      );
      await ref.set(created.toMap());
      return created;
    }

    final existing = AppUser.fromDoc(snap);
    if (existing.displayName == 'メンバー' &&
        fullNameFromApple != null &&
        fullNameFromApple.isNotEmpty) {
      await ref.update({AppUserFields.displayName: fullNameFromApple});
      return AppUser(
        uid: existing.uid,
        displayName: fullNameFromApple,
        householdId: existing.householdId,
        createdAt: existing.createdAt,
      );
    }
    return existing;
  }

  Future<void> setHouseholdId({
    required String uid,
    required String? householdId,
  }) {
    return _doc(uid).update({AppUserFields.householdId: householdId});
  }

  Future<void> deleteUserDoc(String uid) {
    return _doc(uid).delete();
  }

  String _pickName({
    required String? fullNameFromApple,
    required User authUser,
  }) {
    if (fullNameFromApple != null && fullNameFromApple.isNotEmpty) {
      return fullNameFromApple;
    }
    final fromAuth = authUser.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) {
      return fromAuth;
    }
    return 'メンバー';
  }
}
