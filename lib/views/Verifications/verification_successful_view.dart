import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:veriwork_mobile/screens/LoginScreen.dart';
//import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class VerificationSuccessfulView extends StatefulWidget {
  const VerificationSuccessfulView({super.key});

  @override
  State<VerificationSuccessfulView> createState() =>
      _VerificationSuccessfulViewState();
}

class _VerificationSuccessfulViewState
    extends State<VerificationSuccessfulView> {
  void _logout() async {
    // Clear any stored authentication data
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.clear(); // or prefs.remove('token') for specific keys

    // Show logout message
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logged out')));

      // Navigate to login screen and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap: _logout,
        profileImage: const AssetImage('assets/images/default_profile.png'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Verification Complete',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40.0),
            const Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Your identity has been verified successfully. You now have full access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24.0), // Space for Lottie animation
            Lottie.asset(
              'assets/lottie/Successful Verification.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Dashboard...')),
                );
                // Add navigation to dashboard screen here later
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Go to Dashboard'),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
