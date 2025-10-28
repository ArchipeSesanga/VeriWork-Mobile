import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lottie/lottie.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class VerificationRejectedView extends StatefulWidget {
  const VerificationRejectedView({super.key});

  @override
  State<VerificationRejectedView> createState() =>
      _VerificationRejectedViewState();
}

class _VerificationRejectedViewState extends State<VerificationRejectedView> {
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _mobileImagePath = pickedFile.path);
      }
    }
  }

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

  void _retakePhoto() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Retaking photo...')));
    // Add navigation to photo capture screen here
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Contacting support...')));
    // Add navigation or contact logic here
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
              'assets/lottie/Verification Failed.json', // Add a red cross / failed animation
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
    );
  }
}
