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
  int _selectedIndex = 1; // 0 = Home, 1 = Selfie (success = selfie flow)

  Future<void> _logout() async {
    print('VerificationSuccess to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  void _goToDashboard() {
    print('VerificationSuccess to Dashboard');
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      _goToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final textScale = isTablet ? 1.2 : 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap: _logout,
        profileImage: const AssetImage('assets/images/default_profile.png'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16 * textScale),
            Text(
              'Verification Complete',
              style: TextStyle(
                fontSize: 24 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40 * textScale),
            Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 28 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16 * textScale),
            Text(
              'Your identity has been verified successfully. You now have full access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * textScale,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24 * textScale),
            Lottie.asset(
              'assets/lottie/Successful Verification.json',
              width: 200 * textScale,
              height: 200 * textScale,
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
              child: Text(
                'Go to Dashboard',
                style: TextStyle(fontSize: 16 * textScale),
              ),
            ),
            SizedBox(height: 16 * textScale),
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
