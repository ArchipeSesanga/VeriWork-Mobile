import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class VerificationRejectedView extends StatefulWidget {
  const VerificationRejectedView({super.key});

  @override
  State<VerificationRejectedView> createState() =>
      _VerificationRejectedViewState();
}

class _VerificationRejectedViewState extends State<VerificationRejectedView> {
  Future<void> _logout() async {
    print('VerificationRejected to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  void _retakePhoto() {
    print('VerificationRejected to Retake Photo to Selfie');
    Navigator.of(context).pushReplacementNamed(AppRoutes.selfie);
  }

  void _contactSupport() {
    print('VerificationRejected to Contact Support');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening support...')),
    );
    // TODO: Open email, URL, or in-app support
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
              'Verification Failed',
              style: TextStyle(
                fontSize: 24 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40 * textScale),
            Lottie.asset(
              'assets/lottie/Verification Failed.json',
              width: 200 * textScale,
              height: 200 * textScale,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24 * textScale),
            Text(
              'Verification Failed!',
              style: TextStyle(
                fontSize: 28 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16 * textScale),
            Text(
              'Your photo did not match the records.\nPlease retake and resubmit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * textScale,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: _retakePhoto,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red[400]!),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Retake Photo',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16 * textScale,
                ),
              ),
            ),
            SizedBox(height: 12 * textScale),
            ElevatedButton.icon(
              onPressed: _contactSupport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.support_agent),
              label: Text(
                'Contact Support',
                style: TextStyle(fontSize: 16 * textScale),
              ),
            ),
            SizedBox(height: 20 * textScale),
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
