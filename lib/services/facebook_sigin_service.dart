import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacebookSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// ================= FACEBOOK SIGN IN =================
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success ||
          result.accessToken == null) {
        return null;
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'provider': 'facebook',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  /// ================= SIGN OUT =================
  static Future<void> signOut() async {
    await _facebookAuth.logOut();
    await _auth.signOut();
  }

  /// ================= CURRENT USER =================
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}