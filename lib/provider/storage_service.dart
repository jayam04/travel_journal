import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final Reference _storageRef = FirebaseStorage.instance.ref();

  Future<String> uploadImage(File imageFile, String imagePath) async {
    final Reference imageRef = _storageRef.child(imagePath);
    await imageRef.putFile(imageFile);
    return await imageRef.getDownloadURL();
  }
}