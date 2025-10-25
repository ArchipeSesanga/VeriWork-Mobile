import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/models/profile_model.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // get the current logged in user
  User getCurrentUser() {
    User user = firebaseAuth.currentUser!;
    return user;
  }

  Future<bool> loginUser({String? email, String? password}) async {
    var res = await firebaseAuth.signInWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );

    if (res.user != null) {
      // account login was successful
      return true;
    } else {
      // account login was not successful
      return false;
    }
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await firebaseAuth.signOut();
  }

  // Fetch user profile - combine Auth data with minimal Firestore for extended fields
  Future<ProfileModel?> getUserProfile() async {
    final user = getCurrentUser();

    try {
      await user.reload();
      final currentUser = getCurrentUser();

      // Create basic profile from Auth data
      return ProfileModel(
        employeeId: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName?.split(' ').first, // Extract first name
        surname: currentUser.displayName?.split(' ').last, // Extract last name
        imageUrl: currentUser.photoURL,
        phone: currentUser.phoneNumber,
        isVerified: currentUser.emailVerified,
        // Note: Other fields like departmentId, role, position would need
        // to be stored elsewhere or use custom claims
      );
    } catch (_) {
      rethrow;
    }
    return null;
  }

  // Update user profile in Firebase Auth
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    final user = getCurrentUser();

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
    final user = getCurrentUser();

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
    final user = getCurrentUser();
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Error Messages Handeler
  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occured!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains("firebase_auth/invalid-credentials") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else if (e.contains('firebase_auth/network-request-failed')) {
      return 'Please check your internet connection.';
    } else {
      return e;
    }
  }
}
