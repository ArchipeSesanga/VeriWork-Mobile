import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/utils/validations.dart';
import 'package:veriwork_mobile/widgets/showIn_snackbar.dart';

class ForgotPassViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;
  String? email;

  final FocusNode emailFN = FocusNode();

  // ─────────────────────────────────────────────
  // 🔹 RESET INPUT
  // ─────────────────────────────────────────────
  void resetValues() {
    email = null;
  }

  // ─────────────────────────────────────────────
  // 🔹 HANDLE FORGOT PASSWORD (Admin Controlled)
  // ─────────────────────────────────────────────
  Future<void> forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();

    final form = formKey.currentState!;
    form.save();

    // Validate email format
    if (Validations.validateEmail(email) != null) {
      showInSnackBar(
        'Please enter a valid email address.',
        Theme.of(context).colorScheme.error,
        context,
      );
      loading = false;
      notifyListeners();
      return;
    }

    // Show message instead of calling Firebase
    showInSnackBar(
      'Password reset requests can only be processed by an administrator.\n'
      'Please contact your system admin to reset your password.',
      Theme.of(context).colorScheme.primary,
      context,
    );

    loading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // 🔹 SET EMAIL
  // ─────────────────────────────────────────────
  void setEmail(String? val) {
    email = val;
    notifyListeners();
  }
}
