import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_journal/provider/models.dart';

class JournalEntryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch Stream of JournalEntry Map
  Stream<Map<String, JournalEntry>> fetchJournalMapStream(String userId) {
    var ref = _db.collection('users').doc(userId).collection('entries');
    return ref.snapshots().map((querySnapshot) {
      return {
        for (var docSnapshot in querySnapshot.docs)
          docSnapshot.id: JournalEntry.fromFirestore(docSnapshot)
      };
    });
  }

  Future<String> addJournalEntry(String userId, JournalEntry entry) async {
    DocumentReference docRef = await _db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .add(entry.toMap());
    return docRef.id;
  }

  Future<void> updateJournalEntry(String userId, JournalEntry entry) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toMap());
  }
}
