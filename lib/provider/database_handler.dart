import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_journal/provider/models.dart';
import 'package:travel_journal/provider/firebase_service.dart';
import 'package:travel_journal/provider/journal_entry_service.dart';
import 'package:travel_journal/provider/journal_service.dart';
import 'package:travel_journal/provider/user_service.dart';

class DatabaseHandler {
  static bool isFirebaseInitialized = false;

  static final UserService _userService = UserService();
  static final JournalService _journalService = JournalService();
  static final JournalEntryService _journalEntryService = JournalEntryService();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Firebase if not already initialized
  static Future<void> initializeFirebase() async {
    if (!isFirebaseInitialized) {
      await FirebaseService.initializeFirebase().then((value) {
        isFirebaseInitialized = true;
      });
    }
  }

  // Journal-related methods
  static Stream<List<Journal>> fetchJournalStream() {
    log(_auth.currentUser?.uid ?? 'guest');
    return _journalService
        .fetchJournalMapStream(_auth.currentUser?.uid ?? 'guest')
        .map((journalMap) {
      return journalMap.entries.map((entry) => entry.value).toList();
    });
  }

  static Future<String> addJournal(String title, String description) async {
    await initializeFirebase();
    Journal newJournal = Journal(
      id: "TODO",
      title: title,
      description: description,
      userId: _auth.currentUser?.uid ?? "guest",
    );
    String journalId = await _journalService.addJournal(
        _auth.currentUser?.uid ?? "guest", newJournal);
    return journalId;
  }

  static Future<void> deleteJournal(String jouranlId) async {
    await initializeFirebase();
    await _journalService.deleteJouranl(
        _auth.currentUser?.uid ?? "guest", jouranlId);
  }

  static Future<void> setDefaultJournal(String journalId) async {
    await initializeFirebase();
    await _userService.setDefaultJournal(
        _auth.currentUser?.uid ?? "guest", journalId);
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
    var journalEntryMap = await getJournalEntryMap(user);
    log(journalEntryMap.toString(), name: 'Encapsulation');
    if (journalEntryMap.containsKey(entry.journalId)) {
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

  static Future<Map<String, JournalEntry>> getJournalEntryMap(User? user) {
    return _journalEntryService
        .fetchJournalMapStream(user?.uid ?? 'guest')
        .map((journalEntryMap) {
      return journalEntryMap;
    }).first;
  }
}
