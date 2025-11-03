import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/selfie_viewmodel.dart';
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

  // LOGOUT — uses LoginViewModel
  Future<void> _logout() async {
    print('🚨🚨🚨 LOGOUT CALLED - Starting logout process 🚨🚨🚨');
    print('📱 Stack trace for debugging:');
    print(StackTrace.current);

    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    print('🔐 LoginViewModel obtained, calling logoutUser...');
    await viewModel.logoutUser(context);
    print('✅ Logout completed successfully');
  }

  Future<void> _pickImage() async {
    print('📸 _pickImage called - isCapturing: $_isCapturing');
    if (_isCapturing) {
      print('⏳ Already capturing, returning early');
      return;
    }

    setState(() => _isCapturing = true);
    print('🔄 Set _isCapturing to true');

    try {
      print('🎯 Opening camera with ImagePicker...');
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      print(
          '📷 Camera returned - pickedFile: ${pickedFile != null ? "EXISTS" : "NULL"}');
      print('📱 Mounted status: $mounted');

      if (pickedFile != null && mounted) {
        if (kIsWeb) {
          print('🌐 Web platform - reading image as bytes');
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
          print('✅ Web image bytes set - length: ${bytes.length}');
        } else {
          print('📱 Mobile platform - creating File object');
          setState(() {
            _image = File(pickedFile.path);
          });
          print('✅ Mobile image file set - path: ${pickedFile.path}');
        }
      } else {
        print('❌ No image selected or widget not mounted');
      }
    } catch (e) {
      print('❌ ERROR in _pickImage: $e');
      if (mounted) {
        _showSnackBar("Failed to capture selfie. Please try again.", false);
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
        print('🔄 Set _isCapturing to false');
      } else {
        print('⚠️ Widget not mounted, skipping setState');
      }
    }
  }

  Future<void> _submitSelfie() async {
    print('📤 _submitSelfie called - _isLoading: $_isLoading');

    // Check if image exists
    if (_image == null && _webImageBytes == null) {
      print('❌ No image available for submission');
      _showSnackBar("Please capture a selfie first", false);
      return;
    }

    print('🔄 Setting _isLoading to true');
    setState(() => _isLoading = true);

    try {
      print('🔍 Getting SelfieViewModel from Provider');
      final selfieVm = Provider.of<SelfieViewModel>(context, listen: false);

      if (_image != null) {
        print('📁 Setting selfie file in ViewModel');
        selfieVm.setSelfieFile(_image!);
      } else if (_webImageBytes != null) {
        print(
            '🌐 Web image bytes available (length: ${_webImageBytes!.length})');
      }

      print('🚀 Calling uploadSelfie()...');
      final response = await selfieVm.uploadSelfie();
      print('✅ uploadSelfie completed - response: $response');

      final status = response['verificationStatus'] ?? 'pending';
      final message = response['message'] ?? 'Verification completed';
      final isFirstTime = response['isFirstTime'] ?? false;

      print('📊 Verification Status: $status');
      print('📝 Message: $message');
      print('🆕 Is First Time: $isFirstTime');
      print('📱 Mounted status: $mounted');

      if (mounted) {
        _showSnackBar(message, true);
        print('⏳ Waiting 800ms before navigation...');
        await Future.delayed(const Duration(milliseconds: 800));

        print('🧭 Navigating based on verification result...');
        // Navigate based on AUTOMATIC verification result
        if (status == 'verified') {
          print('✅ Verified - navigating to verificationSuccessful');
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationSuccessful);
        } else if (status == 'rejected') {
          print('❌ Rejected - navigating to verificationRejected');
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationRejected);
        } else if (isFirstTime) {
          // First time - reference photo saved
          print('🆕 First time - reference photo saved');
          _showSnackBar(
              "Reference photo saved! Next time will auto-verify.", true);
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationPending);
        } else {
          print('⏳ Pending - navigating to verificationPending');
          Navigator.pushReplacementNamed(
              context, AppRoutes.verificationPending);
        }
      } else {
        print('⚠️ Widget not mounted, skipping navigation');
      }
    } catch (e) {
      print('❌ ERROR in _submitSelfie: $e');
      _showSnackBar("Verification failed: ${e.toString()}", false);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('🔄 Set _isLoading to false');
      } else {
        print('⚠️ Widget not mounted, skipping setState');
      }
    }
  }

  void _showSnackBar(String message, bool success) {
    print('🍫 Showing SnackBar - Success: $success, Message: $message');
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
    print('🏗️ Building SelfiePage UI');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onProfileTap: () {
          print('👤 CustomAppBar onProfileTap triggered!');
          _logout();
        },
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

            // Circular selfie preview
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
                        : Icon(Icons.person_outline,
                            size: 100, color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 40),

            // Capture Selfie Button
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

            // Submit Button
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
        currentIndex: 0,
        onTap: (index) {
          print('🔘 BottomNav tapped - index: $index');
          if (index == 0) {
            print('🏠 Navigating to DashboardScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else if (index == 1) {
            print('👤 Navigating to ProfileView');
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
