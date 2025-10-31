// lib/views/employee/verification_pending_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class VerificationPendingView extends StatefulWidget {
  const VerificationPendingView({super.key});

  @override
  State<VerificationPendingView> createState() =>
      _VerificationPendingViewState();
}

class _VerificationPendingViewState extends State<VerificationPendingView> {
  // LOGOUT — uses LoginViewModel
  Future<void> _logout() async {
    print('VerificationPending to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  // "Back to Home" button
  void _navigateHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap:
            _logout, // ✅ Uses new CustomAppBar without profileImage parameter
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // Keep Home highlighted (or -1 for none)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          }
        },
      ),
    );
  }
}
