// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/core/utils/firebase.dart';
import 'package:veriwork_mobile/widgets/showInSnackBar.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? _email, _password;
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  AuthService auth = AuthService();

  // Setters
  setEmail(email) {
    _email = email;
    notifyListeners(); // Notify listeners when email changes
  }

  setPassword(password) {
    _password = password;
    notifyListeners(); // Notify listeners when email changes
  }

  // reset the provided values
  resetValues() {
    _email = null;
    _password = null;
  }

  //get the authenticated uis
  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

  login(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Please fix the errors in red before submitting.',
          Theme.of(context).colorScheme.error, context);
    } else {
      loading = true;
      notifyListeners();

      try {
        bool success = await auth.loginUser(
          email: _email,
          password: _password,
        );
        if (success) {
          print('Login successful');
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        showInSnackBar(auth.handleFirebaseAuthError(e.toString()),
            Theme.of(context).colorScheme.error, context);
      }

      loading = false;
      notifyListeners();
    }
  }

  logoutUser(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      await auth.logOut();
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar(
          e.toString(), Theme.of(context).colorScheme.error, context);
    }
  }
}
