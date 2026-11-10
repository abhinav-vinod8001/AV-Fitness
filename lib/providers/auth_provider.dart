import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

const String _webClientId = '861922031134-ptgn8qchnuodpg2adrbq0a8rg5h8eq4j.apps.googleusercontent.com';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthController {
  final FirebaseAuth _auth;
  bool _initialized = false;
  
  AuthController(this._auth);

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      _initialized = true;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web uses the Popup sign in
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      return await _auth.signInWithPopup(authProvider);
    } else {
      // Mobile uses the Google Sign In plugin
      try {
        await _ensureInitialized();
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      } catch (e, stackTrace) {
        debugPrint('Google Sign-In Error: $e\n$stackTrace');
        rethrow;
      }
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
    }
    return credential;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _ensureInitialized();
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google Sign-Out silent ignore: $e');
      }
    }
    await _auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});
