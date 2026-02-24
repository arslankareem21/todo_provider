import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider_todo_app/model/user_model.dart';



class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _appUser;
  User? _firebaseUser;

  AppUser? get appUser => _appUser;
  User? get firebaseUser => _firebaseUser;

  bool _loading = false;
  bool get loading => _loading;

  UserProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _appUser = null;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        _appUser = AppUser.fromMap(doc.data()!);
      } else {
        _appUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoURL: user.photoURL,
          provider: user.providerData.isNotEmpty ? user.providerData[0].providerId : '',
        );
      }
    } catch (e) {
      _appUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoURL: user.photoURL,
        provider: user.providerData.isNotEmpty ? user.providerData[0].providerId : '',
      );
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_firebaseUser == null) return;

    _loading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        _appUser = AppUser.fromMap(doc.data()!);
      }
    } catch (e) {
      // ignore or handle error
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _appUser = null;
    _firebaseUser = null;
    notifyListeners();
  }
}
