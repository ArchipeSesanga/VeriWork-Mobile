// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch Firestore user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchUserProfile();
    });
  }

  void _logout() async {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logged out')));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final profile = vm.userProfile;
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
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await vm.fetchUserProfile();
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.03),
                          // ───────────────────────────────
                          // Profile Picture
                          // ───────────────────────────────
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF5B7CB1), width: 3),
                              image: DecorationImage(
                                image: profile?.imageUrl != null &&
                                        profile!.imageUrl!
                                            .isNotEmpty //  FIX: Use imageUrl, not documentUrls
                                    ? NetworkImage(profile.imageUrl!)
                                        as ImageProvider
                                    : const AssetImage('assets/profile.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // ───────────────────────────────
                          // Name + ID
                          // ───────────────────────────────
                          Text(
                            '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                            style: TextStyle(
                              fontSize: 20 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.employeeId ??
                                profile?.uid ??
                                '', //  FIX: Use employeeId instead of just uid
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
                          // ───────────────────────────────
                          // User Information Section
                          // ───────────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoLabel('JOB TITLE', textScale),
                              _infoValue(profile?.position, textScale),
                              _infoLabel('DEPARTMENT', textScale),
                              _infoValue(profile?.departmentId, textScale),
                              _infoLabel('EMAIL ADDRESS', textScale),
                              _infoValue(profile?.email, textScale),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          // ───────────────────────────────
                          // Edit Profile Button
                          // ───────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileView()),
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
                                'View Full Profile', //  Changed text to be more accurate
                                style: TextStyle(
                                  fontSize: 16 * textScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // ───────────────────────────────
                          // Verification Section
                          // ───────────────────────────────
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6 * textScale),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: 0.2),
                              border: Border.all(
                                  color: Colors.orangeAccent, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              profile?.verificationStatus ??
                                  'Pending', //  FIX: Use actual verification status
                              style: TextStyle(
                                color: Colors.orange,
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.06),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────
  //  Helper Widgets
  // ───────────────────────────────
  Widget _infoLabel(String text, double textScale) => Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 12 * textScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey),
        ),
      );

  Widget _infoValue(String? value, double textScale) => Text(
        value ?? 'Not available',
        style: TextStyle(fontSize: 16 * textScale, fontWeight: FontWeight.w500),
      );
}
