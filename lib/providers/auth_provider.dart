import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../conts/firebase/firestore_constants.dart';


enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
  authenticateChecking,
}

class AuthProviderlocal extends ChangeNotifier {

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  Status _status = Status.uninitialized;
  Status get status => _status;
  String? _lastAuthenticationError;
  String? get lastAuthenticationError => _lastAuthenticationError;
  set lastAuthenticationError(String? value) {
    _lastAuthenticationError = value;
    notifyListeners(); // Notify listeners when the value changes
  }
  AuthProviderlocal(
      {
      required this.firebaseAuth,
      required this.firebaseFirestore,
      required this.prefs});

  String? getFirebaseUserId() {
    return prefs.getString(FirestoreConstants.id);
  }


  Future<bool> isLoggedIn() async {
    var isLoggedIn = false;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        isLoggedIn = false;
      } else {
        isLoggedIn = true;
      }
    });
    if (isLoggedIn &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signInUsingEmailPassword({required String email,required String password,}) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      _status = Status.authenticating;
      notifyListeners();
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      print(user.toString());
      if (user != null) {
        await prefs.setString(FirestoreConstants.id, user.uid);
        await prefs.setString(
            FirestoreConstants.displayName, user.displayName ?? "");
        await prefs.setString(
            FirestoreConstants.photoUrl, user.photoURL ?? "");
        await prefs.setString(
            FirestoreConstants.phoneNumber, user.phoneNumber ?? "");
        _status = Status.authenticated;
        notifyListeners();
        return true;

      }
      else{
        print("NO USER FOUND");
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar('Account does"t exist', 'Please Register first',
            backgroundColor: Colors.orangeAccent);
        if (kDebugMode) {
          print(e.code);
        }
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          Get.snackbar(
              'Login unsuccessful!', 'Please check username and password',
              backgroundColor: Colors.orangeAccent);
          print(e.code);
        }

        _status = Status.authenticateError;
        notifyListeners();
        return false;

      }
    }
    _status = Status.authenticateChecking;
    notifyListeners();
    return false;
  }

  Future<bool> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    required String photoURL,
    required String phoneNumber,
  }) async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user!.updateProfile(displayName: name, photoURL: photoURL);
      await user.reload();

      if (user != null) {
        DocumentSnapshot document = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(user.uid)
            .get();

        if (!document.exists) {
          await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(user.uid)
              .set({
            FirestoreConstants.displayName: name,
            FirestoreConstants.photoUrl: photoURL,
            FirestoreConstants.id: user.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.phoneNumber: phoneNumber,
          });
        } else {
          await firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(user.uid)
              .update({
            FirestoreConstants.displayName: name,
            FirestoreConstants.photoUrl: photoURL,
            FirestoreConstants.phoneNumber: phoneNumber,
            FirestoreConstants.id: user.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
          });
        }

        await prefs.setString(FirestoreConstants.id, user.uid);
        await prefs.setString(
            FirestoreConstants.displayName, name ?? "");
        await prefs.setString(
            FirestoreConstants.photoUrl, photoURL ?? "");
        await prefs.setString(
            FirestoreConstants.phoneNumber, phoneNumber ?? "");
        Fluttertoast.showToast(
            msg: "Succefully Register", backgroundColor: Colors.green);
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Fluttertoast.showToast(
            msg: "The password provided is too weak.", backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email.", backgroundColor: Colors.red);
        print('The account already exists for that email.');
      }
      lastAuthenticationError = e.code;
      print('Firebase authentication error: ${e.message}');
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error during user registration: $e');
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future <bool> registerUsinggoogle() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: 'AIzaSyBowPwIo3rKO7OgYW2Rih8JuRhtVhJgUug.apps.googleusercontent.com');
    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount!.authentication;
    User? user;
    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        ),
      );
      user = userCredential.user;
      await user!.updateProfile(displayName: user.displayName);
      await user.reload();
      user = auth.currentUser;
      if (user != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if (document.isEmpty) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(user.uid)
              .set({
            FirestoreConstants.displayName: user.displayName,
            FirestoreConstants.photoUrl: user.photoURL,
            FirestoreConstants.id: user.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            "online": "ONLINE",

          });

          User? currentUser = user;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.displayName, currentUser.displayName ?? "");
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        } else {

        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      _status = Status.authenticateError;
      return false;
    }

  }

  sendPasswordResetEmail({required String email,}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Reset','Password Link Send on Email check it!',backgroundColor: Colors.deepPurpleAccent);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Fail!', ' ${e.code}',backgroundColor: Colors.deepPurpleAccent);
      Get.snackbar('Fail!', '${e.message}',backgroundColor: Colors.deepPurpleAccent);
    }
  }

  static Future<User?>signInAnonymously() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          Get.snackbar('Fail!', "Anonymous auth hasn't been enabled for this project.", backgroundColor: Colors.greenAccent);
          break;
        default:
          Get.snackbar('Fail!', "Unknown error.", backgroundColor: Colors.greenAccent);
      }
    }
    return user;
  }
  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
  Future<void> signOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();

  }

}
