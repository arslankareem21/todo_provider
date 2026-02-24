import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider_todo_app/services/facebook_sigin_service.dart';
import 'package:provider_todo_app/services/google_sigin_service.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  bool loading = false;
  String? error;

  AuthProvider() {
    user = FirebaseAuth.instance.currentUser;
  }

  /// ================= EMAIL LOGIN =================
  Future<void> login(String email, String password) async {
    try {
      loading = true;
      notifyListeners();

      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      user = cred.user;
      error = null;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ================= REGISTER =================
  Future<void> register(String email, String password, String name) async {
    try {
      loading = true;
      notifyListeners();

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = cred.user;

      if (user != null) {
        // Update display name in Firebase Auth profile
        await user.updateDisplayName(name);

        // Save user data in Firestore
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'photoURL': user.photoURL ?? '',
            'provider': 'email',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      this.user = user;
      error = null;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ================= GOOGLE LOGIN =================
  Future<void> loginWithGoogle() async {
    try {
      loading = true;
      notifyListeners();

      final userCred = await GoogleSignInService.signInWithGoogle();

      user = userCred?.user;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ================= FACEBOOK LOGIN =================
  Future<void> loginWithFacebook() async {
    try {
      loading = true;
      notifyListeners();

      final userCred = await FacebookSignInService.signInWithFacebook();

      user = userCred?.user;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ================= FORGOT PASSWORD =================
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      error = "Password reset email sent";
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await GoogleSignInService.signOut();
    await FacebookSignInService.signOut();
    await FirebaseAuth.instance.signOut();
    user = null;
    notifyListeners();
  }
}
