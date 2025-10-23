import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/models/profile_model.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  // Fetch user profile - combine Auth data with minimal Firestore for extended fields
  Future<ProfileModel?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      await user.reload();
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Create basic profile from Auth data
        return ProfileModel(
          employeeId: currentUser.uid,
          email: currentUser.email,
          name: currentUser.displayName?.split(' ').first, // Extract first name
          surname:
              currentUser.displayName?.split(' ').last, // Extract last name
          imageUrl: currentUser.photoURL,
          phone: currentUser.phoneNumber,
          isVerified: currentUser.emailVerified,
          // Note: Other fields like departmentId, role, position would need
          // to be stored elsewhere or use custom claims
        );
      }
    } catch (_) {
      rethrow;
    }
    return null;
  }

  // Sign in user with email & password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (context != null && context.mounted) {
        _handleAuthError(e, context);
      }
    } catch (_) {
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Sign in failed. Please try again.');
      }
    }
    return null;
  }

  // Update user profile in Firebase Auth
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      if (phoneNumber != null) {
        // Note: Phone number update requires reauthentication
        // await user.updatePhoneNumber(phoneNumber);
      }

      await user.reload();
    } catch (_) {
      rethrow;
    }
  }

  // Update user email
  Future<void> updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Reauthenticate before changing email
      final credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail.trim());
      await user.reload();
    } catch (_) {
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Handle FirebaseAuth errors
  void _handleAuthError(FirebaseAuthException e, BuildContext context) {
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address.';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Please try again later.';
        break;
      case 'email-already-in-use':
        errorMessage = 'This email is already registered.';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak.';
        break;
      case 'requires-recent-login':
        errorMessage = 'Please sign in again to update your email.';
        break;
      default:
        errorMessage = 'Authentication failed. Please try again.';
    }

    _showErrorSnackBar(context, errorMessage);
  }

  // Show error SnackBar safely
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Sign out user
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();

      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on FirebaseAuthException {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Sign out failed. Please try again.');
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'An unexpected error occurred.');
      }
    }
  }

  // Check if user is verified (using email verification from Auth)
  Future<bool> isUserVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Stream for user profile changes (from Auth only)
  Stream<ProfileModel?> get userProfileStream {
    return _auth.userChanges().asyncMap((user) {
      if (user != null) {
        return ProfileModel(
          employeeId: user.uid,
          email: user.email,
          name: user.displayName?.split(' ').first,
          surname: user.displayName?.split(' ').last,
          imageUrl: user.photoURL,
          phone: user.phoneNumber,
          isVerified: user.emailVerified,
        );
      }
      return null;
    });
  }

  // Get user metadata
  Map<String, dynamic>? get userMetadata {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
    };
  }

  // Delete user account
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Reauthenticate before deletion
      final credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      await user.delete();
    } catch (_) {
      rethrow;
    }
  }
}
