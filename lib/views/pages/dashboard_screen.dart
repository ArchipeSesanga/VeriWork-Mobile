// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchUserProfile();
    });
  }

  Future<void> _logout() async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  // Helper method to get status details based on verification status
  Map<String, dynamic> _getStatusDetails(String? verificationStatus) {
    switch (verificationStatus?.toLowerCase()) {
      case 'verified':
      case 'approved':
        return {
          'text': 'Active Employee',
          'color': Color(0xFF4CAF50),
          'backgroundColor': Color(0xFFE8F5E8),
          'borderColor': Color(0xFF4CAF50),
          'icon': Icons.verified_outlined,
        };
      case 'rejected':
      case 'denied':
        return {
          'text': 'Verification Rejected',
          'color': Color(0xFFF44336),
          'backgroundColor': Color(0xFFFFEBEE),
          'borderColor': Color(0xFFF44336),
          'icon': Icons.error_outline,
        };
      case 'pending':
      default:
        return {
          'text': 'Pending Verification',
          'color': Color(0xFFFF9800),
          'backgroundColor': Color(0xFFFFF3E0),
          'borderColor': Color(0xFFFF9800),
          'icon': Icons.pending_outlined,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DashboardViewModel>(context);
    final profile = vm.userProfile;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final statusDetails = _getStatusDetails(profile?.verificationStatus);

    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap: _logout,
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async => vm.fetchUserProfile(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade50,
                              Colors.blue.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Avatar with Status Badge
                            Center(
                              child: Stack(
                                alignment: Alignment
                                    .bottomRight, // keep badge bottom-right
                                children: [
                                  Container(
                                    width: isTablet ? 120 : 100,
                                    height: isTablet ? 120 : 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      backgroundImage:
                                          profile?.imageUrl != null &&
                                                  profile!.imageUrl!.isNotEmpty
                                              ? NetworkImage(profile.imageUrl!)
                                              : const AssetImage(
                                                      'assets/profile.jpg')
                                                  as ImageProvider,
                                    ),
                                  ),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusDetails['backgroundColor'],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusDetails['borderColor'],
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: .1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statusDetails['icon'],
                                          color: statusDetails['color'],
                                          size: isTablet ? 12 : 10,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusDetails['text']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: statusDetails['color'],
                                            fontSize: isTablet ? 10 : 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Name and ID
                            Text(
                              '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.employeeId ?? profile?.uid ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Personal Information Section
                      _buildSection(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          _buildInfoRow(
                            icon: Icons.work_outline,
                            label: 'Job Title',
                            value: profile?.position ?? 'Not available',
                          ),
                          _buildInfoRow(
                            icon: Icons.business_outlined,
                            label: 'Department',
                            value: profile?.departmentId ?? 'Not available',
                          ),
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: profile?.email ?? 'Not available',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Verification Status Section
                      _buildSection(
                        title: 'Verification Status',
                        icon: Icons.verified_outlined,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: statusDetails['backgroundColor'],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusDetails['borderColor'],
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusDetails['color']
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: statusDetails['color'],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusDetails['icon'],
                                            color: statusDetails['color'],
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            profile?.verificationStatus
                                                    ?.toUpperCase() ??
                                                'PENDING',
                                            style: TextStyle(
                                              color: statusDetails['color'],
                                              fontSize: isTablet ? 12 : 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      statusDetails['icon'],
                                      color: statusDetails['color'],
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getStatusMessage(
                                      profile?.verificationStatus),
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.profileSettings,
                              ),
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 20),
                              label: Text(
                                'View Full Profile',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Only show selfie button if status is not verified/approved
                          if (profile?.verificationStatus?.toLowerCase() !=
                                  'verified' &&
                              profile?.verificationStatus?.toLowerCase() !=
                                  'approved')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.selfie,
                                ),
                                icon: const Icon(Icons.camera_alt_outlined,
                                    size: 20),
                                label: Text(
                                  'Capture Verification Selfie',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1976D2),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color(0xFF1976D2),
                                      width: 2,
                                    ),
                                  ),
                                  elevation: 1,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          }
        },
      ),
    );
  }

  String _getStatusMessage(String? verificationStatus) {
    switch (verificationStatus?.toLowerCase()) {
      case 'verified':
      case 'approved':
        return 'Your identity has been successfully verified. You now have full access to all employee features.';
      case 'rejected':
      case 'denied':
        return 'Your verification was rejected. Please capture a new selfie and try again, or contact support for assistance.';
      case 'pending':
      default:
        return 'Please capture a selfie for identity verification to complete your profile setup and activate your account.';
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
