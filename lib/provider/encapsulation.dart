import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/provider/auth_provider.dart';
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
  static Stream<List<Journal>> fetchJournalStream(User? user) {
    log(user?.uid ?? 'guest');
    return _journalService
        .fetchJournalMapStream(user?.uid ?? 'guest')
        .map((journalMap) {
      journalMap = journalMap;
      return journalMap.entries.map((entry) => entry.value).toList();
    });
  }

  // JournalEntry-related methods
  static Stream<List<JournalEntry>> fetchJournalEntryStream(User? user) {
    return _journalEntryService
        .fetchJournalMapStream(user?.uid ?? 'guest')
        .map((journalEntryMap) {
      return journalEntryMap.entries.map((entry) => entry.value).toList();
    });
  }

  static Future<void> addOrUpdateJournalEntry(
      User? user, JournalEntry entry) async {
    if (!journalMap.keys.contains(entry.id)) {
      await _journalEntryService.addJournalEntry(user?.uid ?? 'guest', entry);
    } else {
      await _journalEntryService.updateJournalEntry(user?.uid ?? 'guest', entry);
    }
  }
}
