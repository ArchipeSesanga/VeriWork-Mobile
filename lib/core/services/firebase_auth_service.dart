import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/models/profile_model.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Get the currently logged-in Firebase user
  User getCurrentUser() {
    return firebaseAuth.currentUser!;
  }

  /// Login user with email and password
  Future<bool> loginUser(
      {required String email, required String password}) async {
    try {
      final res = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return res.user != null;
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    }
  }

  /// Forgot password (send reset email)
  Future<void> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    }
  }

  /// Log out the current user
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  /// Fetch user profile - combines Firebase Auth and Firestore data
  Future<ProfileModel?> getUserProfile() async {
    final user = getCurrentUser();

    try {
      await user.reload();
      final doc = await firestore.collection('employees').doc(user.uid).get();

      if (!doc.exists) return null;
      final data = doc.data()!;

      return ProfileModel(
        employeeId: user.uid,
        email: user.email ?? data['Email'],
        name: user.displayName?.split(' ').first ?? data['Name'],
        surname: user.displayName?.split(' ').last ?? data['Surname'],
        imageUrl: user.photoURL ??
            (data['DocumentUrls'] != null
                ? (data['DocumentUrls'] as List).isNotEmpty
                    ? data['DocumentUrls'][0]
                    : null
                : null),
        phone: user.phoneNumber ?? data['Phone'],
        departmentId: data['DepartmentId'],
        isVerified: user.emailVerified,
        role: data['Role'],
        address: data['Address'],
        city: data['City'],
        country: data['Country'],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile in Firebase Auth
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
        // Note: Updating phone number requires reauthentication.
        // await user.updatePhoneNumber(phoneNumber);
      }

      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    }
  }

  /// Update user's email address
  Future<void> updateEmail(String newEmail, String password) async {
    final user = getCurrentUser();

    try {
      // Reauthenticate before changing email
      final credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    }
  }

  /// Send email verification to the current user
  Future<void> sendEmailVerification() async {
    final user = getCurrentUser();
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Optional: Register new user (for signup screens)
  Future<User?> registerUser(String email, String password) async {
    try {
      final res = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return res.user;
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthError(e.code);
    }
  }

  /// Error message handler for FirebaseAuth exceptions
  String handleFirebaseAuthError(String e) {
    if (e.contains("weak-password")) {
      return "Password is too weak.";
    } else if (e.contains("invalid-email")) {
      return "Invalid email address.";
    } else if (e.contains("email-already-in-use")) {
      return "This email is already used by another account.";
    } else if (e.contains("network-request-failed")) {
      return "Please check your internet connection.";
    } else if (e.contains("user-not-found")) {
      return "No user found with these credentials.";
    } else if (e.contains("wrong-password")) {
      return "Incorrect password.";
    } else if (e.contains("requires-recent-login")) {
      return "Please log in again before performing this action.";
    } else {
      return "Authentication error: $e";
    }
  }
}
