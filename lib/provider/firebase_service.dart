import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseApp? _firebaseApp;

  static Future<void> initializeFirebase() async {
    _firebaseApp ??= await Firebase.initializeApp();
  }

  static bool isInitialized() {
    return _firebaseApp != null;
  }

  static FirebaseApp? get firebaseApp => _firebaseApp;
}
