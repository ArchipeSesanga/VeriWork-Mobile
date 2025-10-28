// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/core/utils/validations.dart';
import 'package:veriwork_mobile/widgets/showIn_snackbar.dart';

class ForgotPassViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? email;
  FocusNode emailFN = FocusNode();
  AuthService auth = AuthService();

  resetValues() {
    email = null;
  }

  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    if (Validations.validateEmail(email) != null) {
      showInSnackBar('Please input a valid email to reset your password.',
          Theme.of(context).colorScheme.error, context);
    } else {
      try {
        await auth.forgotPassword(email!);
        showInSnackBar(
            'Please check your email for instructions '
            'to reset your password',
            Theme.of(context).colorScheme.primary,
            context);
      } catch (e) {
        showInSnackBar(
            e.toString(), Theme.of(context).colorScheme.error, context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }
}
