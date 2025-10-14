import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Fixed conditional import (same as profile_view.dart)
import '../../utils/image_picker_web.dart' if (dart.library.html) '../../utils/image_picker_web.dart' if (dart.library.io) '../../utils/image_picker_mobile.dart';

import '../../models/profile_model.dart';

class VerificationPendingView extends StatefulWidget {
  const VerificationPendingView({super.key});

  @override
  State<VerificationPendingView> createState() => _VerificationPendingViewState();
}

class _VerificationPendingViewState extends State<VerificationPendingView> {
  late ProfileModel _profile;
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _logout() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  void _navigateHome() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Navigating to Home')));
  }

  void _navigateProfile() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Already on Verification Pending')));
  }

  @override
  void initState() {
    super.initState();
    _profile = ProfileModel(
      name: '',
      employeeId: '',
      departmentId: '',
      email: '',
      phone: '',
      imageUrl: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background as specified
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Going back...')),
                );
              },
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
            Center(
              child: Icon(
                Icons.access_time, // Placeholder for Lottie clock animation
                size: 100,
                color: const Color.fromARGB(255, 0, 0, 0),
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
            const Spacer(), // Pushes button and icons to the bottom
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Home...')),
                );
                // Add navigation to home screen here later
              },
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
    );
  }
}