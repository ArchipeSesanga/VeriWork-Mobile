import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProfileModel? _userProfile;
  bool _isLoading = true;

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
      if (kDebugMode) debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  void _logout() async {
    print('Dashboard to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context); // Uses ViewModel for consistency
  }

  void _goToEditProfile() {
    print('Dashboard to Edit Profile');
    Navigator.pushNamed(context, AppRoutes.profileSettings);
  }

  void _goToSelfie() {
    print('Dashboard to Capture Selfie');
    Navigator.pushNamed(context, AppRoutes.selfie);
  }

  String _getFullName() =>
      '${_userProfile?.name ?? ''} ${_userProfile?.surname ?? ''}'
              .trim()
              .isEmpty
          ? 'Loading...'
          : '${_userProfile!.name} ${_userProfile!.surname}';

  String _getEmployeeId() => _userProfile?.employeeId ?? 'Employee ID: Not Set';
  String _getPosition() => _userProfile?.position ?? 'Position not set';
  String _getDepartment() => _userProfile?.departmentId ?? 'Department not set';
  String _getEmail() => _userProfile?.email ?? 'Email not set';
  String _getPhone() => _userProfile?.phone ?? 'Phone not set';
  String _getRole() => _userProfile?.role ?? 'Role not set';
  bool _isVerified() => _userProfile?.isVerified ?? false;
  String _getVerificationStatus() =>
      _userProfile?.verificationStatus ?? 'Pending Review';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = isTablet ? 32.0 : 16.0;
        final avatarSize = isTablet ? 140.0 : 100.0;
        final textScale = isTablet ? 1.3 : 1.0;

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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.03),

                          // Avatar (centered)
                          Center(
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF5B7CB1), width: 3),
                                image: _userProfile?.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            _userProfile!.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage('assets/profile.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          // Name & ID (centered)
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _getFullName(),
                                  style: TextStyle(
                                      fontSize: 20 * textScale,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getEmployeeId(),
                                  style: TextStyle(
                                      fontSize: 14 * textScale,
                                      color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Active Badge (centered)
                          Center(
                            child: Container(
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
                          ),
                          SizedBox(height: size.height * 0.04),

                          // Info Fields (left-aligned)
                          _buildInfoRow('JOB TITLE', _getPosition(), textScale),
                          _buildInfoRow(
                              'DEPARTMENT', _getDepartment(), textScale),
                          _buildInfoRow(
                              'EMAIL ADDRESS', _getEmail(), textScale),
                          _buildInfoRow('PHONE NUMBER', _getPhone(), textScale),
                          _buildInfoRow('ROLE', _getRole(), textScale),

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
                                _isVerified() ? 'Verified' : 'Not Verified',
                                style: TextStyle(
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w500,
                                  color: _isVerified()
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.03),

                          // Edit Profile Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goToEditProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
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

                          SizedBox(height: size.height * 0.04),

                          // Verification Section (left-aligned)
                          Text(
                            'Verification Status',
                            style: TextStyle(
                                fontSize: 16 * textScale,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Current Status:',
                            style: TextStyle(fontSize: 14 * textScale),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6 * textScale),
                            decoration: BoxDecoration(
                              color: _getVerificationStatus() == 'Verified'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                              border: Border.all(
                                color: _getVerificationStatus() == 'Verified'
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getVerificationStatus(),
                              style: TextStyle(
                                color: _getVerificationStatus() == 'Verified'
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12 * textScale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please capture a selfie for verification.',
                            style: TextStyle(
                                fontSize: 14 * textScale, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          // Capture Selfie Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goToSelfie,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 18.0 : 14.0),
                              ),
                              child: Text(
                                'Capture Verification Selfie',
                                style: TextStyle(
                                  fontSize: 15 * textScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.06),
                        ],
                      ),
                    ),
                  ),
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: 0, // Dashboard/Home is selected
            onTap: (index) {
              if (index == 1) {
                // Navigate to Profile
                Navigator.pushNamed(context, AppRoutes.profileSettings);
              }
              // index 0 is already on Dashboard, so do nothing
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              TextStyle(fontSize: 16 * textScale, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
