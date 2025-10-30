// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchUserProfile();
    });
  }

  Future<void> _logout() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged out')));
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    await loginVM.logoutUser(context);
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.profileSettings);
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
            onProfileTap: () =>
                Navigator.pushNamed(context, AppRoutes.profileSettings),
            profileImage: const AssetImage('assets/images/default_profile.png'),
          ),

          body: SafeArea(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => vm.fetchUserProfile(),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.03),

                          Center(
                            child: Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF5B7CB1), width: 3),
                                image: DecorationImage(
                                  image: profile?.imageUrl != null &&
                                          profile!.imageUrl!.isNotEmpty
                                      ? NetworkImage(profile.imageUrl!)
                                          as ImageProvider
                                      : const AssetImage('assets/profile.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                                  style: TextStyle(
                                      fontSize: 20 * textScale,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile?.employeeId ?? profile?.uid ?? '',
                                  style: TextStyle(
                                      fontSize: 14 * textScale,
                                      color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

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
                          SizedBox(height: screenHeight * 0.04),

                          _infoLabel('JOB TITLE', textScale),
                          _infoValue(profile?.position, textScale),
                          _infoLabel('DEPARTMENT', textScale),
                          _infoValue(profile?.departmentId, textScale),
                          _infoLabel('EMAIL ADDRESS', textScale),
                          _infoValue(profile?.email, textScale),

                          SizedBox(height: screenHeight * 0.03),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.profileSettings),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 18.0 : 14.0),
                              ),
                              child: Text(
                                'View Full Profile',
                                style: TextStyle(
                                  fontSize: 16 * textScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),

                          Text(
                            'Verification Status',
                            style: TextStyle(
                                fontSize: 16 * textScale,
                                fontWeight: FontWeight.bold),
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
                              profile?.verificationStatus ?? 'Pending',
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

                          // FULL WIDTH: Selfie Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.selfie),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
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
                          SizedBox(height: screenHeight * 0.06),
                        ],
                      ),
                    ),
                  ),
          ),

          // BOTTOM NAV: Home + Profile
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            selectedItemColor: const Color(0xFF1976D2),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

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

