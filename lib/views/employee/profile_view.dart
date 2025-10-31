import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchUserProfile();
    });
  }

  // LOGOUT
  Future<void> _logout() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final profile = vm.userProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap:
            _logout, // ✅ Uses new CustomAppBar without profileImage parameter
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
              children: [
                const Text(
                  'Profile Information',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),

                // Profile Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow[50],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 50 : 40,
                          backgroundImage: profile?.imageUrl != null &&
                                  profile!.imageUrl!.isNotEmpty
                              ? NetworkImage(profile.imageUrl!) as ImageProvider
                              : const AssetImage('assets/profile.jpg'),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              profile?.employeeId ?? profile?.uid ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32.0),

                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                _buildInfoField(
                  label: 'Full Name',
                  value: '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Employee ID',
                  value: profile?.employeeId ?? profile?.uid ?? '',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Position',
                  value: profile?.position ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Department',
                  value: profile?.departmentId ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Email Address',
                  value: profile?.email ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Phone Number',
                  value: profile?.phone ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Role',
                  value: profile?.role ?? 'Not specified',
                  isTablet: isTablet,
                ),

                const SizedBox(height: 24.0),

                // Contact Information Section
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                _buildInfoField(
                  label: 'Address',
                  value: profile?.address ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'City',
                  value: profile?.city ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Country',
                  value: profile?.country ?? 'Not specified',
                  isTablet: isTablet,
                ),

                const SizedBox(height: 24.0),

                // Emergency Contact Section
                const Text(
                  'Emergency Contact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                _buildInfoField(
                  label: 'Emergency Contact Name',
                  value: profile?.emergencyName ?? 'Not specified',
                  isTablet: isTablet,
                ),
                _buildInfoField(
                  label: 'Emergency Contact Phone',
                  value: profile?.emergencyPhone ?? 'Not specified',
                  isTablet: isTablet,
                ),

                const SizedBox(height: 32.0),

                // Verification Status
                const Text(
                  'Verification Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(profile?.verificationStatus)
                        .withValues(
                            alpha:
                                0.1), // Fixed: changed withValues to withOpacity
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: _getStatusColor(profile?.verificationStatus),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(profile?.verificationStatus),
                        color: _getStatusColor(profile?.verificationStatus),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Status',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              profile?.verificationStatus ?? 'Pending',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: _getStatusColor(
                                    profile?.verificationStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40.0),
              ],
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1, // Profile is selected
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        },
      ),
    );
  }

  // Helper method for status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  // Helper method for status icon
  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.pending;
    }
  }

  // Read-only information field widget
  Widget _buildInfoField({
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[50],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
