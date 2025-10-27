import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch user profile from Firestore
  Stream<ProfileModel?> getUserProfileStream(String userId) {
    return _firestore
        .collection('employees')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return ProfileModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Fetch user profile once (non-streaming)
  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('employees').doc(userId).get();
      if (doc.exists) {
        return ProfileModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('employees').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');

      UploadTask uploadTask;
      if (imageFile != null) {
        uploadTask = ref.putFile(imageFile);
      } else if (imageBytes != null) {
        uploadTask = ref.putData(imageBytes);
      } else {
        throw Exception('No image provided');
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Update profile with photo
  Future<void> updateProfileWithPhoto({
    required String userId,
    required Map<String, dynamic> profileData,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      // Upload photo if provided
      if (imageFile != null || imageBytes != null) {
        final photoUrl = await uploadProfilePhoto(
          userId: userId,
          imageFile: imageFile,
          imageBytes: imageBytes,
        );
        profileData['PhotoUrl'] = photoUrl;
      }

      // Update profile data
      await updateProfile(userId: userId, updates: profileData);
    } catch (e) {
      throw Exception('Failed to update profile with photo: $e');
    }
  }

  // Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      await _storage.ref().child('profile_photos/$userId.jpg').delete();
    } catch (e) {
      // Photo might not exist, ignore error
    }
  }

  // Update specific fields
  Future<void> updateName(String userId, String name, String surname) async {
    await updateProfile(
      userId: userId,
      updates: {'Name': name, 'Surname': surname},
    );
  }

  Future<void> updateEmail(String userId, String email) async {
    await updateProfile(userId: userId, updates: {'Email': email});
  }

  Future<void> updatePhone(String userId, String phone) async {
    await updateProfile(userId: userId, updates: {'Phone': phone});
  }

  Future<void> updateAddress(String userId, String address) async {
    await updateProfile(userId: userId, updates: {'Address': address});
  }
}
