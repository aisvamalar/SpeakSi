
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  User? get currentUser => _auth.currentUser;


  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      await _createUserProfile(userCredential.user!.uid, {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'profileCompleted': false,
      });

      await userCredential.user!.updateDisplayName(name);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      await _updateLastLogin(userCredential.user!.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign In was cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await _createUserProfile(userCredential.user!.uid, {
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'profileCompleted': false,
        });
      } else {
        await _updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }


  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Sign out failed';
    }
  }


  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in';


      if (displayName != null || photoURL != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) await user.updatePhotoURL(photoURL);
      }


      if (additionalData != null) {
        await _firestore.collection('users').doc(user.uid).update({
          ...additionalData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Profile update failed';
    }
  }

  Future<void> _createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
    }
  }
}