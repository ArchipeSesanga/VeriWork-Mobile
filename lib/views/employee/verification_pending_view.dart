import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
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
  int _selectedIndex = 1; // 0 = Home, 1 = Profile (pending = post-selfie)

  Future<void> _logout() async {
    print('VerificationPending to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  void _navigateHome() {
    print('VerificationPending to Dashboard');
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  void _navigateToProfile() {
    print('VerificationPending to Profile');
    Navigator.of(context).pushReplacementNamed(AppRoutes.profileSettings);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      _navigateHome();
    } else if (index == 1) {
      _navigateToProfile();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: _navigateHome,
              tooltip: 'Back to Dashboard',
            ),
            SizedBox(height: 16 * textScale),

            // Title
            Center(
              child: Text(
                'Verification Pending',
                style: TextStyle(
                  fontSize: 24 * textScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 32 * textScale),

            // Clock Icon
            const Center(
              child: Icon(
                Icons.access_time,
                size: 100,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16 * textScale),

            // Message
            Center(
              child: Text(
                'Your verification is pending',
                style: TextStyle(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8 * textScale),
            Center(
              child: Text(
                'HR is reviewing your photo. You will be notified once the process is complete.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * textScale,
                  color: Colors.grey,
                ),
              ),
            ),

            const Spacer(),

            // Back to Home Button
            ElevatedButton(
              onPressed: _navigateHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Back to Home',
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
