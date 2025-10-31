import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class VerificationRejectedView extends StatefulWidget {
  const VerificationRejectedView({super.key});

  @override
  State<VerificationRejectedView> createState() =>
      _VerificationRejectedViewState();
}

class _VerificationRejectedViewState extends State<VerificationRejectedView> {
  // LOGOUT — uses LoginViewModel
  Future<void> _logout() async {
    print('VerificationPending to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  // RETAKE PHOTO → SelfiePage
  void _retakePhoto() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Retaking photo...')));
    Navigator.pushReplacementNamed(context, AppRoutes.selfie);
  }

  // CONTACT SUPPORT → Placeholder (expand later)
  void _contactSupport() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Contacting support...')));
    // TODO: Open email, support page, or in-app chat
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
              'Verification Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40.0),
            Lottie.asset(
              'assets/lottie/Verification Failed.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Verification Failed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Your photo did not match the records.\nPlease retake and resubmit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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
              child: const Text(
                'Retake Photo',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12.0),
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
              label: const Text(
                'Contact Support',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      // NO BOTTOM NAVIGATION — AS REQUESTED
    );
  }
}
