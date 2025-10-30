import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/models/profile_model.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  //  GET CURRENT USER PROFILE
  // ─────────────────────────────────────────────
  Future<ProfileModel?> getCurrentUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        return null;
      }

      final doc = await _firestore.collection('Users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }

      return ProfileModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
}
