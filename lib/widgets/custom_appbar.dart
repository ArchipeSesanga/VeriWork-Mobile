import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;
  final ImageProvider<Object> profileImage;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
                  onPressed: () => viewModel.logoutUser(context),
                  tooltip: 'Logout',
                ),
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: isTablet ? 26 : 20,
                    backgroundImage: profileImage,
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
