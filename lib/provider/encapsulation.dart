import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/firebase_service.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:travel_journal/provider/journal_service.dart';

class DatabaseEncapsulation {
  static bool isFirebaseInitialized = false;

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
  static Stream<List<Journal>> fetchJournalStream(User? user) {
    log(user?.uid ?? 'guest');
    return _journalService
        .fetchJournalMapStream(user?.uid ?? 'guest')
        .map((journalMap) {
      return journalMap.entries.map((entry) => entry.value).toList();
    });
  }

  // JournalEntry-related methods
  static Stream<List<JournalEntry>> fetchJournalEntryStream(User? user) {
    return _journalEntryService
        .fetchJournalMapStream(user?.uid ?? 'guest')
        .map((journalEntryMap) {
      return journalEntryMap.entries.map((entry) => entry.value).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  static Future<void> addOrUpdateJournalEntry(
      User? user, JournalEntry entry) async {
    var journalMap = await getJournalMap(user);
    if (journalMap.containsKey(entry.journalId)) {
      await _journalEntryService.updateJournalEntry(
          user?.uid ?? 'guest', entry);
    } else {
      await _journalEntryService.addJournalEntry(user?.uid ?? 'guest', entry);
    }
  }

  static Future<Map<String, Journal>> getJournalMap(User? user) {
    return _journalService.fetchStream(user?.uid ?? 'guest').map((journalList) {
      return {
        for (var journal in journalList) journal.id: journal,
      };
    }).first;
  }
}
