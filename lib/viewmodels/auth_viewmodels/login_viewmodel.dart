// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/core/utils/firebase.dart';
import 'package:veriwork_mobile/widgets/showInSnackBar.dart';
import 'package:veriwork_mobile/widgets/showIn_snackbar.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;

  String? _email;
  String? _password;

  final FocusNode emailFN = FocusNode();
  final FocusNode passFN = FocusNode();

  final AuthService _authService = AuthService();

  // ─────────────────────────────────────────────
  // 🔹 SETTERS
  // ─────────────────────────────────────────────
  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String? password) {
    _password = password;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // 🔹 RESET INPUT FIELDS
  // ─────────────────────────────────────────────
  void resetValues() {
    _email = null;
    _password = null;
  }

  // ─────────────────────────────────────────────
  //  GET CURRENT USER UID
  // ─────────────────────────────────────────────
  String get currentUid => firebaseAuth.currentUser!.uid;

  // ─────────────────────────────────────────────
  //  LOGIN USER
  // ─────────────────────────────────────────────
  Future<void> login(BuildContext context) async {
    final form = formKey.currentState!;
    form.save();

    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
        'Please fix the errors in red before submitting.',
        Theme.of(context).colorScheme.error,
        context,
      );
      return;
    }

    // 🔹 Check for null values
    if (_email == null || _password == null) {
      showInSnackBar(
        'Please enter both email and password.',
        Theme.of(context).colorScheme.error,
        context,
      );
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final success = await _authService.loginUser(
        email: _email!.trim(), // ✅ Safe unwrapping
        password: _password!.trim(),
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      showInSnackBar(
        _authService.handleFirebaseAuthError(e.toString()),
        Theme.of(context).colorScheme.error,
        context,
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  //  LOGOUT USER
  // ─────────────────────────────────────────────
  Future<void> logoutUser(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      await _authService.logOut();
      // TODO: Navigate back to login screen after logout
    } catch (e) {
      showInSnackBar(
        e.toString(),
        Theme.of(context).colorScheme.error,
        context,
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  //  OPTIONAL: EMAIL & PASSWORD VALIDATION HELPERS
  // ─────────────────────────────────────────────
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }
}
