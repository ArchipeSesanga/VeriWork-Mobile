import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Uint8List? _webImageBytes;
  String? _mobileImagePath;
  ProfileModel? _userProfile;
  bool _isLoading = true;

  VoidCallback get _logout => () {
        // Implement logout functionality
      };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final profile = await authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user profile: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        // TODO: Upload image to Firebase Storage and update Firestore profile
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImageBytes = bytes);
        } else {
          setState(() => _mobileImagePath = pickedFile.path);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update image: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileView()),
      );
    }
  }

  String _getFullName() {
    if (_userProfile == null) return 'Loading...';
    return '${_userProfile?.name ?? ''} ${_userProfile?.surname ?? ''}'.trim();
  }

  String _getEmployeeId() {
    return _userProfile?.employeeId ?? 'Employee ID: Not Set';
  }

  String _getPosition() {
    return _userProfile?.position ?? 'Position not set';
  }

  String _getDepartment() {
    return _userProfile?.departmentId ?? 'Department not set';
  }

  String _getEmail() {
    return _userProfile?.email ?? 'Email not set';
  }

  bool _isVerified() {
    return _userProfile?.isVerified ?? false;
  }

  String _getVerificationStatus() {
    return _userProfile?.verificationStatus ?? 'Pending Review';
  }

  String _getRole() {
    // ✅ FIXED: Added fallback string to avoid syntax error
    return _userProfile?.role ?? 'Role not set';
  }

  String _getPhone() {
    return _userProfile?.phone ?? 'Phone not set';
  }

  ImageProvider<Object> _getImageProvider() {
    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    } else if (!kIsWeb && _mobileImagePath != null) {
      return FileImage(File(_mobileImagePath!));
    }

    // Fallback to network image from Firestore
    if (_userProfile?.imageUrl != null && _userProfile!.imageUrl!.isNotEmpty) {
      return NetworkImage(_userProfile!.imageUrl!);
    }

    return const AssetImage('assets/profile_banner.png');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = isTablet ? 32.0 : 16.0;
        double avatarSize = isTablet ? 140 : 100;
        double textScale = isTablet ? 1.3 : 1.0;

        return Scaffold(
          appBar: CustomAppBar(
            onProfileTap: _logout,
            profileImage: const AssetImage('assets/images/default_profile.png'),
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
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
                              border: Border.all(
                                  color: const Color(0xFF5B7CB1), width: 3),
                              image: _userProfile?.imageUrl != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(_userProfile!.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : const DecorationImage(
                                      image: AssetImage('assets/profile.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            _getFullName(),
                            style: TextStyle(
                              fontSize: 20 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getEmployeeId(),
                            style: TextStyle(
                              fontSize: 14 * textScale,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                              Text(_getPosition(),
                                  style: TextStyle(
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Text('DEPARTMENT',
                                  style: TextStyle(
                                      fontSize: 12 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_getDepartment(),
                                  style: TextStyle(
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Text('EMAIL ADDRESS',
                                  style: TextStyle(
                                      fontSize: 12 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_getEmail(),
                                  style: TextStyle(
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Text('PHONE NUMBER',
                                  style: TextStyle(
                                      fontSize: 12 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_getPhone(),
                                  style: TextStyle(
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Text('ROLE',
                                  style: TextStyle(
                                      fontSize: 12 * textScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_getRole(),
                                  style: TextStyle(
                                      fontSize: 16 * textScale,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: _isVerified()
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                      _isVerified()
                                          ? 'Verified'
                                          : 'Not Verified',
                                      style: TextStyle(
                                          fontSize: 14 * textScale,
                                          fontWeight: FontWeight.w500,
                                          color: _isVerified()
                                              ? Colors.green
                                              : Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to Edit Profile screen
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
                              color: _getVerificationStatus() == 'Verified'
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orangeAccent.withValues(alpha: 0.3),
                              border: Border.all(
                                  color: _getVerificationStatus() == 'Verified'
                                      ? Colors.green
                                      : Colors.orange,
                                  width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getVerificationStatus(),
                              style: TextStyle(
                                  color: _getVerificationStatus() == 'Verified'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12 * textScale,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Please capture a selfie for verification.',
                              style: TextStyle(
                                  fontSize: 14 * textScale,
                                  color: Colors.grey)),
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
