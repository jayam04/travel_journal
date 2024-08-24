import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_journal/provider/models.dart';

class JournalEntryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Redundent code to be removed
  Stream<List<JournalEntry>> fetchStream(String userId) {
    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc('guest')
        .collection('entries');
    return ref.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return JournalEntry.fromFirestore(docSnapshot);
      }).toList();
    });
  }

  // Fetch Stream of JournalEntry Map
  Stream<Map<String, JournalEntry>> fetchJournalMapStream(String userId) {
    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('entries');
    return ref.snapshots().map((querySnapshot) {
      return {
        for (var docSnapshot in querySnapshot.docs)
          docSnapshot.id: JournalEntry.fromFirestore(docSnapshot)
      };
    });
  }

  Future<String> addJournalEntry(String userId, JournalEntry entry) async {
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('entries')
        .add(entry.toMap());
    return docRef.id;
  }

  Future<void> updateJournalEntry(String userId, JournalEntry entry) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toMap());
  }
}
