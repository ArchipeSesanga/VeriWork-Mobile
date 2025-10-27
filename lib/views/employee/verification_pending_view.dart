import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart'; // Assuming ProfileView for consistency
import 'package:veriwork_mobile/core/constants/routes.dart'; // Added for navigation

class VerificationPendingView extends StatefulWidget {
  const VerificationPendingView({super.key});

  @override
  State<VerificationPendingView> createState() => _VerificationPendingViewState();
}

class _VerificationPendingViewState extends State<VerificationPendingView> {
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImageBytes = bytes);
      }
    } else {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _mobileImagePath = pickedFile.path;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to pick image: $e')));
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _navigateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard); // Back to Dashboard
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Center(
            child: Image.asset(
              'assets/images/Logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: kIsWeb
                        ? (_webImageBytes != null
                            ? MemoryImage(_webImageBytes!)
                            : const AssetImage('assets/profile_banner.png')
                                as ImageProvider<Object>)
                        : (_mobileImagePath != null
                            ? FileImage(File(_mobileImagePath!))
                            : const AssetImage('assets/profile_banner.png')
                                as ImageProvider<Object>),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () => _navigateHome(), // Back to Dashboard
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: _navigateHome,
                        tooltip: 'Home',
                      ),
                      const Text('Home'),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: _navigateProfile,
                        tooltip: 'Profile',
                      ),
                      const Text('Profile'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  