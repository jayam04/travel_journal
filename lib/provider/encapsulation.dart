import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/firebase_service.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:travel_journal/provider/journal_service.dart';

class DatabaseEncapsulation {
  static bool isFirebaseInitialized = false;

  static Map<String, Journal> journalMap = {};

  static final JournalService _journalService = JournalService();
  static final JournalEntryService _journalEntryService = JournalEntryService();

  // Initialize Firebase if not already initialized
  static Future<void> initializeFirebase() async {
    if (!isFirebaseInitialized) {
      await FirebaseService.initializeFirebase().then((value) {
        isFirebaseInitialized = true;
      });
    }
  }

  // Journal-related methods
  static Stream<List<Journal>> fetchJournalStream(String userId) {
    return _journalService.fetchJournalMapStream(userId).map((journalMap) {
      journalMap = journalMap;
      return journalMap.entries.map((entry) => entry.value).toList();
    });
  }

  // JournalEntry-related methods
  static Stream<List<JournalEntry>> fetchJournalEntryStream(String userId) {
    return _journalEntryService
        .fetchJournalMapStream(userId)
        .map((journalEntryMap) {
      return journalEntryMap.entries.map((entry) => entry.value).toList();
    });
  }
}
