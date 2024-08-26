import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_journal/provider/models.dart';

class JournalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Redundent
  Stream<List<Journal>> fetchStream(String userId) {
    var ref = _db.collection('users').doc(userId).collection('journals');
    return ref.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Journal.fromFirestore(docSnapshot);
      }).toList();
    });
  }

  // Fetch Stream of Journal Map
  Stream<Map<String, Journal>> fetchJournalMapStream(String userId) {
    var ref = _db.collection('users').doc(userId).collection('journals');
    return ref.snapshots().map((querySnapshot) {
      return {
        for (var docSnapshot in querySnapshot.docs)
          docSnapshot.id: Journal.fromFirestore(docSnapshot)
      };
    });
  }

  Future<String> addJournal(String userId, Journal journal) async {
    var ref = _db.collection('users').doc(userId).collection('journals');
    DocumentReference documentReference = await ref.add(journal.toMap());

    return documentReference.id;
  }

  Future<void> deleteJouranl(String userId, String journalId) async {
    var ref = _db.collection('users').doc(userId).collection('journals');
    await ref.doc(journalId).delete();
  }
}
