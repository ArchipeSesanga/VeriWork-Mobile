import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isFaceDetected = false; // Placeholder for face detection

  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
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
            _isFaceDetected = true; // Simulate face detection
          });
        } else {
          setState(() {
            _mobileImagePath = pickedFile.path;
            _image = File(pickedFile.path);
            _isFaceDetected = true; // Simulate face detection
          });
        }
      }
    } catch (e) {
      if (mounted) {
        print('PickImage Error: $e');
        _showSnackBar("Failed to capture selfie. Please try again.", false);
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _submitSelfie() async {
    if (_image == null && _webImageBytes == null) {
      _showSnackBar("Please capture a selfie first", false);
      return;
    }
    if (!_isFaceDetected) {
      _showSnackBar("No face detected. Please try again with a clear selfie.", false);
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
      String fileName = 'selfies/$employeeId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Uploading to: $fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = FirebaseStorage.instance
            .ref(fileName)
            .putData(_webImageBytes!);
      } else {
        uploadTask = FirebaseStorage.instance
            .ref(fileName)
            .putFile(_image!);
      }

      final snapshot = await uploadTask.whenComplete(() {
        print('Upload complete for: $fileName');
      });
      final downloadURL = await snapshot.ref.getDownloadURL();
      print('Download URL: $downloadURL');

      await FirebaseFirestore.instance.collection('verifications').doc(employeeId).set({
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
          Navigator.pushReplacementNamed(context, '/verification_pending');
        }
      }
    } catch (e) {
      print('Submit Error: $e');
      if (mounted) {
        _showSnackBar("Submission failed: $e. Please try again.", false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('Loading state reset');
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
              const SizedBox(width: 12),
            ],
          ),
        ],
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
                  color: _image != null || _webImageBytes != null
                      ? (_isFaceDetected ? Colors.green : Colors.red)
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
            if (_image != null || _webImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _isFaceDetected ? "Face detected!" : "No face detected",
                  style: TextStyle(
                    color: _isFaceDetected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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
                onPressed: _isLoading ? null : _submitSelfie,
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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}