import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  File? _image;
  bool _isLoading = false;
  bool _isCapturing = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _logout() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  // Load profile image from user data
  Future<void> _loadProfileImage() async {
    try {
      final dashboardVm =
          Provider.of<DashboardViewModel>(context, listen: false);
      await dashboardVm.fetchUserProfile();

      final profile = dashboardVm.userProfile;
      if (profile?.imageUrl != null && profile!.imageUrl!.isNotEmpty) {
        setState(() {
          _profileImageUrl = profile.imageUrl;
        });
        print('Loaded profile image: $_profileImageUrl');
      } else {
        print('No profile image found');
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null && mounted) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to capture selfie. Please try again.", false);
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<String?> _uploadSelfieToFirebase() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      String userId = user.uid;
      String fileName =
          'verification_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = 'users/$userId/verification_selfies/$fileName';

      Reference storageRef = _storage.ref().child(filePath);

      if (kIsWeb) {
        if (_webImageBytes != null) {
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploaded_by': userId,
              'user_email': user.email ?? 'unknown',
              'uploaded_at': DateTime.now().toIso8601String(),
              'purpose': 'verification',
            },
          );

          await storageRef.putData(_webImageBytes!, metadata);
          return await storageRef.getDownloadURL();
        }
      } else {
        if (_image != null) {
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploaded_by': userId,
              'user_email': user.email ?? 'unknown',
              'uploaded_at': DateTime.now().toIso8601String(),
              'purpose': 'verification',
            },
          );

          await storageRef.putFile(_image!, metadata);
          return await storageRef.getDownloadURL();
        }
      }

      return null;
    } catch (e) {
      print('Firebase upload error: $e');
      throw Exception('Failed to upload selfie to Firebase: $e');
    }
  }

  Future<void> _submitSelfie() async {
    if (_image == null && _webImageBytes == null) {
      _showSnackBar("Please capture a selfie first", false);
      return;
    }

    if (_auth.currentUser == null) {
      _showSnackBar("Please log in to upload selfies", false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload to Firebase Storage
      _showSnackBar("Uploading selfie...", true);
      String? downloadUrl = await _uploadSelfieToFirebase();

      if (downloadUrl != null) {
        print('Selfie uploaded successfully: $downloadUrl');
        _showSnackBar("Selfie uploaded successfully!", true);
      }

      // Compare with profile image
      _showSnackBar("Comparing with profile photo...", true);
      await Future.delayed(const Duration(seconds: 2));

      final comparisonResult = await _compareWithProfileImage();

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate based on comparison result
        if (comparisonResult['status'] == 'verified') {
          _showSnackBar("Identity verified! ✅", true);
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationSuccessful);
        } else if (comparisonResult['status'] == 'rejected') {
          _showSnackBar(
              "Verification failed: ${comparisonResult['message']}", false);
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationRejected);
        } else if (comparisonResult['status'] == 'no_profile_image') {
          _showSnackBar("No profile image found for comparison", false);
          // Optionally navigate to profile setup
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationPending);
        }
      }
    } catch (e) {
      _showSnackBar("Upload failed: ${e.toString()}", false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Compare new selfie with profile image
  Future<Map<String, dynamic>> _compareWithProfileImage() async {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      return {
        'status': 'no_profile_image',
        'message': 'No profile image available for comparison',
        'confidence': 0.0,
        'hasProfileImage': false,
      };
    }

    print('Comparing with profile image: $_profileImageUrl');

    // Simulate image comparison logic
    final comparisonScore = _simulateImageComparison();

    print('Comparison score with profile image: $comparisonScore');

    if (comparisonScore >= 0.8) {
      // High match - verified
      return {
        'status': 'verified',
        'message': 'High match with profile photo',
        'confidence': comparisonScore,
        'hasProfileImage': true,
      };
    } else if (comparisonScore >= 0.5) {
      // Medium match - might need manual review
      return {
        'status': 'verified', // or 'pending' for manual review
        'message': 'Moderate match with profile photo',
        'confidence': comparisonScore,
        'hasProfileImage': true,
      };
    } else {
      // Low match - rejected
      return {
        'status': 'rejected',
        'message': 'Low similarity with profile photo',
        'confidence': comparisonScore,
        'hasProfileImage': true,
      };
    }
  }

  // Simulate image comparison (replace with real logic when available)
  double _simulateImageComparison() {
    final random = DateTime.now().millisecond;

    // Simulate different comparison scenarios
    if (random % 4 == 0) {
      return 0.95; // Excellent match
    } else if (random % 4 == 1) {
      return 0.75; // Good match
    } else if (random % 4 == 2) {
      return 0.45; // Poor match
    } else {
      return 0.25; // Very poor match
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = Provider.of<DashboardViewModel>(context);
    final profile = dashboardVm.userProfile;
    final User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap: _logout,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Identity Verification",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Take a selfie to compare with your profile photo",
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            // Show profile image and user info
            if (user != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Profile image thumbnail
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.blue.shade300, width: 2),
                      ),
                      child: ClipOval(
                        child: _profileImageUrl != null
                            ? Image.network(_profileImageUrl!,
                                fit: BoxFit.cover)
                            : Icon(Icons.person,
                                size: 30, color: Colors.blue.shade400),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comparing with:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            profile?.imageUrl != null
                                ? 'Profile Photo'
                                : 'No Profile Photo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Current selfie preview
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _image != null || _webImageBytes != null
                      ? Colors.blueAccent
                      : Colors.grey.shade300,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : _webImageBytes != null
                        ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt_outlined,
                            size: 60, color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              _image != null || _webImageBytes != null
                  ? 'New Selfie'
                  : 'Capture Selfie',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCapturing ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCapturing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Capture Selfie",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_image != null || _webImageBytes != null) && !_isLoading
                        ? _submitSelfie
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Verify Identity",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            // Demo info
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    "🔍 Comparing with Profile Photo",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profileImageUrl != null
                        ? "Will compare new selfie with your profile image"
                        : "No profile image found for comparison",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
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
