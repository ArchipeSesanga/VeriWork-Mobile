import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService(this._auth) : _firestore = FirebaseFirestore.instance;

  // Fetch user profile data from Firestore (keep this)
  Future<ProfileModel?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ProfileModel.fromMap({
          ...data,
          'employeeId': user.uid,
        });
      }
    } catch (_) {
      rethrow;
    }
    return null;
  }

  // Sign in user with email & password (Auth only)
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

      final user = userCredential.user;
      if (user != null) {
        // Update last logged in timestamp in Firestore
        await _firestore.collection('Users').doc(user.uid).update({
          'LastLoggedIn': FieldValue.serverTimestamp(),
        });
        return user;
      }
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

  // Handle FirebaseAuth errors with user-friendly messages
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
      default:
        errorMessage = 'Sign in failed. Please try again.';
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

  // Check if user is verified (from Firestore)
  Future<bool> isUserVerified() async {
    final profile = await getUserProfile();
    return profile?.isVerified ?? false;
  }

  // Update last active timestamp in Firestore
  Future<void> updateLastActive() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'LastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  // Send password reset email (Auth only)
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

  // Stream for user profile changes (from Firestore)
  Stream<ProfileModel?> get userProfileStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user != null) {
        return _firestore.collection('Users').doc(user.uid).snapshots().map(
          (doc) {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              return ProfileModel.fromMap({
                ...data,
                'employeeId': user.uid,
              });
            }
            return null;
          },
        );
      }
      return Stream.value(null);
    });
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update(updates);
    }
  }

  // Update profile image URL in Firestore
  Future<void> updateProfileImage(String imageUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'PhotoUrl': imageUrl,
      });
    }
  }
}
