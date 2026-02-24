import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        // 🌐 Web Google login
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // 📱 Android Google login
        final googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;

        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw FirebaseAuthException(
            code: "ERROR_MISSING_ID_TOKEN",
            message: "Missing Google ID Token",
          );
        }

        final credential = GoogleAuthProvider.credential(idToken: idToken);
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Save user in Firestore if new
      final user = userCredential.user;
      if (user != null) {
        final doc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        if (!(await doc.get()).exists) {
          await doc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print("Google sign-in error: $e");
      rethrow;
    }
  }

  static Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}