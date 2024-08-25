import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setDefaultJournal(String userId, String journalId) {
    log(userId, name: "userId");
    DocumentReference userRef = _db.collection('users').doc(userId);
    // TODO: use update instead of set.
    return userRef.set({
      'defaultJournal': journalId,
    });
  }

  Future<String> getDefaultJournal(String userId) async {
    DocumentSnapshot userSnapshot =
        await _db.collection('users').doc(userId).get();
    return userSnapshot.get('defaultJournal') ?? '';
  }
}