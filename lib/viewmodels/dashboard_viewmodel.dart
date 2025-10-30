import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veriwork_mobile/models/profile_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileModel? userProfile;
  bool isLoading = false;

  Future<void> fetchUserProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection('Users').doc(uid).get();
        if (doc.exists) {
          userProfile = ProfileModel.fromFirestore(doc);
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
