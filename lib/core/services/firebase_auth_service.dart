import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  //  LOGIN USER
  // ─────────────────────────────────────────────
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user != null;
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    } catch (e) {
      throw "Unexpected error: ${e.toString()}";
    }
  }

  // ─────────────────────────────────────────────
  //  LOGOUT USER
  // ─────────────────────────────────────────────
  // In your AuthService
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // ─────────────────────────────────────────────
  //  HELPER: HANDLE ERRORS
  // ─────────────────────────────────────────────
  String handleFirebaseAuthError(String code) {
    switch (code) {
      case "invalid-email":
        return "Invalid email address.";
      case "user-disabled":
        return "This account has been disabled.";
      case "user-not-found":
        return "No user found with these credentials.";
      case "wrong-password":
        return "Incorrect password.";
      case "network-request-failed":
        return "Please check your internet connection.";
      default:
        return "Authentication error: $code";
    }
  }

  // Optional: access the current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;
}
