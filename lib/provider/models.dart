import 'package:cloud_firestore/cloud_firestore.dart';

class Journal {
  String id;
  String title;
  String userId;
  String description;
  List<JournalEntry>? entries;

  Journal({
    required this.id,
    required this.title,
    required this.userId,
    required this.description,
    this.entries,
  });

  // Factory method to create a Journal from Firestore data
  factory Journal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Journal(
      id: doc.id,
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      entries: (data['entries'] as List?)
          ?.map((entry) => JournalEntry.fromFirestore(entry))
          .toList(),
    );
  }

  // Method to convert Journal to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'userId': userId,
      'entries': entries?.map((entry) => entry.toMap()).toList(),
    };
  }
}

class JournalEntry {
  String id;
  String title;
  String journalId;
  String content;
  Timestamp timestamp;
  List<String>? photos;
  GeoPoint? location;

  JournalEntry({
    required this.id,
    required this.title,
    required this.journalId,
    required this.content,
    required this.timestamp,
    this.photos,
    this.location,
  });

  // Factory method to create a JournalEntry from Firestore data
  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      title: data['title'] ?? 'Kuch to Kar lo',
      journalId: data['journalId'] ?? '',
      content: data['content'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      location: data['location'] as GeoPoint?,
      timestamp: Timestamp.now(),
    );
  }

  // Method to convert JournalEntry to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'journalId': journalId,
      'content': content,
      'timestamp': timestamp,
      'photos': photos,
      'location': location,
    };
  }
}
