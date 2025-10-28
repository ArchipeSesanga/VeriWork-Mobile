import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> logoutUser(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear stored authentication data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // or use prefs.remove('token') for specific keys

      _isLoading = false;
      notifyListeners();

      // Check if context is still valid
      if (context.mounted) {
        // Show logout message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );

        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }
}
