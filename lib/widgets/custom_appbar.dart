import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/logout_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart'; // Use DashboardViewModel to get profile

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardVm = Provider.of<DashboardViewModel>(context,
        listen: true); //  Listen to changes
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final profile = dashboardVm.userProfile;

    //  Dynamic profile image
    final ImageProvider profileImage =
        profile?.imageUrl != null && profile!.imageUrl!.isNotEmpty
            ? NetworkImage(profile.imageUrl!) as ImageProvider
            : const AssetImage('assets/images/default_profile.png');

    return AppBar(
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      title: Stack(
        children: [
          // Centered logo
          Center(
            child: Image.asset(
              'assets/images/Logo.png',
              height: isTablet ? 60 : 40,
              fit: BoxFit.contain,
            ),
          ),
          // Right side actions
          Positioned(
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () =>
                      authViewModel.showLogoutConfirmation(context),
                  tooltip: 'Logout',
                ),
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: isTablet ? 26 : 20,
                    backgroundImage: profileImage, //  Now uses dynamic image
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
