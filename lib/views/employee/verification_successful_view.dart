import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class VerificationSuccessfulView extends StatefulWidget {
  const VerificationSuccessfulView({super.key});

  @override
  State<VerificationSuccessfulView> createState() =>
      _VerificationSuccessfulViewState();
}

class _VerificationSuccessfulViewState
    extends State<VerificationSuccessfulView> {
  int _selectedIndex = 0; // 0 = Home, 1 = Profile

  // LOGOUT — uses LoginViewModel
  Future<void> _logout() async {
    print('VerificationSuccessful to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  // BOTTOM NAV TAP
  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.profileSettings);
    }
  }

  // "Go to Dashboard" button
  void _goToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Dashboard...')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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
            const SizedBox(height: 24.0),
            Lottie.asset(
              'assets/lottie/Successful Verification.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _goToDashboard,
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
