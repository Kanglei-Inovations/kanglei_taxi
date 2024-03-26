import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ProfileProvider(
      {required this.prefs,
      required this.firebaseStorage,
      required this.firebaseFirestore});

  String? getPrefs(String key) {
    return prefs.getString(key);
  }

  Future<bool> setPrefs(String key, String value) async {
    return await prefs.setString(key, value);
  }

  UploadTask uploadImageFile(File image, String fileName) {
    final path = 'profile/${fileName}';
    Reference reference = firebaseStorage.ref().child(path);
    UploadTask uploadTask = reference.putFile(image);
    print(uploadTask.toString());
    return uploadTask;
  }
  Future<void> updateFirestoreData(String collectionPath, String path,
      Map<String, dynamic> dataUpdateNeeded) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataUpdateNeeded);
  }
  Future<void> updatelocation(String collectionPath, String path,
      String location) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update({"location": location});
  }

  Future<void> updateFireAuthen(String photoUrl) async {
    return FirebaseAuth.instance.currentUser!.updateProfile(photoURL: photoUrl);
  }
}
