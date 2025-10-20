import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
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

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = isTablet ? 32.0 : 16.0;
        double avatarSize = isTablet ? 140 : 100;
        double textScale = isTablet ? 1.3 : 1.0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[700],
            title: Center(
              child: Image.asset(
                'assets/images/Logo.png',
                height: isTablet ? 60 : 40,
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
                      radius: isTablet ? 26 : 20,
                      backgroundImage: kIsWeb
                          ? (_webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : const AssetImage('assets/profile_banner.png')
                                  as ImageProvider<Object>)
                          : (_mobileImagePath != null
                              ? FileImage(File(_mobileImagePath!))
                              : const AssetImage('assets/profile_banner.png')
                                  as ImageProvider<Object>),
                    ),
                  ),
                  SizedBox(width: isTablet ? 20 : 12),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF5B7CB1), width: 3),
                      image: const DecorationImage(
                        image: AssetImage('assets/profile.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Samantha Doe',
                    style: TextStyle(
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Employee ID: EMP1245',
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6 * textScale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Active Employee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * textScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JOB TITLE',
                          style: TextStyle(
                              fontSize: 12 * textScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('Senior Software Engineer',
                          style: TextStyle(
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 16),
                      Text('DEPARTMENT',
                          style: TextStyle(
                              fontSize: 12 * textScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('Engineering',
                          style: TextStyle(
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 16),
                      Text('EMAIL ADDRESS',
                          style: TextStyle(
                              fontSize: 12 * textScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('jane.doe@company.com',
                          style: TextStyle(
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 18.0 : 14.0),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Verification Status',
                      style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Current Status:',
                      style: TextStyle(
                          fontSize: 14 * textScale,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6 * textScale),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.3),
                      border: Border.all(color: Colors.orange, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pending Review',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12 * textScale,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Please capture a selfie for verification.',
                      style: TextStyle(
                          fontSize: 14 * textScale, color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelfiePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 18.0 : 14.0),
                      ),
                      child: Text(
                        'Capture Verification Selfie',
                        style: TextStyle(
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
