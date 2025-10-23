import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService(this._auth) : _firestore = FirebaseFirestore.instance;

  Future<ProfileModel?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        return ProfileModel.fromMap(
            {...doc.data() as Map<String, dynamic>, 'IdNumber': user.uid});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
    return null;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'Last Logged In': FieldValue.serverTimestamp(),
        });

        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (context.mounted) {}
      rethrow;
    }
  }
}
