import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/employee/dashboard_view.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _faceDetected = false; // Placeholder for face detection
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes;

  int _selectedIndex = 1; // 0 = Home, 1 = Selfie

  Future<void> _logout() async {
    print('Selfie to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      print('Selfie to Dashboard (Bottom Nav)');
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  Future<void> _pickImage() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _faceDetected = false;
    });

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
            _faceDetected = true; // Simulate face detection
          });
        } else {
          setState(() {
            _image = File(pickedFile.path);
            _faceDetected = true; // Simulate face detection
          });
        }

        print('Selfie to Face Detected to Ready to Submit');
        _showFaceDetectedFeedback();
      }
    } catch (e) {
      print('PickImage Error: $e');
      if (mounted) {
        _showSnackBar("Failed to capture selfie. Please try again.", false);
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showFaceDetectedFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Face Detected! Ready to submit."),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitSelfie() async {
    if (!_faceDetected) {
      _showSnackBar("Please capture a clear selfie first.", false);
      return;
    }

    setState(() => _isLoading = true);
    print('Submitting selfie...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar("Please log in first.", false);
        setState(() => _isLoading = false);
        return;
      }

      final employeeId = user.uid;
      print('Employee ID: $employeeId');
      String fileName =
          'selfies/$employeeId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Uploading to: $fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        if (_webImageBytes == null) throw Exception('No web image data');
        uploadTask =
            FirebaseStorage.instance.ref(fileName).putData(_webImageBytes!);
      } else {
        if (_image == null) throw Exception('No mobile image file');
        uploadTask = FirebaseStorage.instance.ref(fileName).putFile(_image!);
      }

      final snapshot = await uploadTask.whenComplete(() {
        print('Upload complete for: $fileName');
      });
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('Download URL: $downloadURL');

      await FirebaseFirestore.instance
          .collection('verifications')
          .doc(employeeId)
          .set({
        'employeeId': employeeId,
        'selfieUrl': downloadURL,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Firestore document created for: $employeeId');

      if (mounted) {
        _showSnackBar("Selfie submitted successfully!", true);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.verificationPending);
        }
      }
    } catch (e) {
      print('Submit Error: $e');
      if (mounted) {
        _showSnackBar("Submission failed: $e. Please try again.", false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap: _logout,
        profileImage: const AssetImage('assets/images/default_profile.png'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Take Photo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Take a clear selfie for verification",
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Circular selfie preview with face detection feedback
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _faceDetected
                      ? Colors.green
                      : (_image != null || _webImageBytes != null
                          ? Colors.blueAccent
                          : Colors.grey.shade300),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : _webImageBytes != null
                        ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                        : Icon(Icons.person_outline,
                            size: 100, color: Colors.grey.shade400),
              ),
            ),

            // Face Detected Badge
            if (_faceDetected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Face Detected! Ready to submit.",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Capture Selfie Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCapturing ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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

            // Submit Button (enabled only if face detected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _faceDetected && !_isLoading ? _submitSelfie : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
                        "Submit",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // Keep Home highlighted (or -1 for none)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardView()),
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
