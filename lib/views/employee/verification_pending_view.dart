import 'package:flutter/material.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class VerificationPendingView extends StatefulWidget {
  const VerificationPendingView({super.key});

  @override
  State<VerificationPendingView> createState() =>
      _VerificationPendingViewState();
}

class _VerificationPendingViewState extends State<VerificationPendingView> {
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
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'Verification Pending',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            const Center(
              child: Icon(
                Icons.access_time,
                size: 100,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                'Your verification is pending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            const Center(
              child: Text(
                'HR is reviewing your photo. You will be notified once the process is complete.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _navigateHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
