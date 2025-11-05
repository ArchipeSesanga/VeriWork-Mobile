// ignore_for_file: prefer_const_constructors

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
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      // Profile Avatar with Status Badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: isTablet ? 100 : 80,
                            height: isTablet ? 100 : 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: profile?.imageUrl != null &&
                                      profile!.imageUrl!.isNotEmpty
                                  ? NetworkImage(profile.imageUrl!)
                                  : const AssetImage('assets/profile.jpg')
                                      as ImageProvider,
                            ),
                          ),
                          // Dynamic Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusDetails['backgroundColor'],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusDetails['borderColor'],
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
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
                                  size: isTablet ? 10 : 8,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  statusDetails['text']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: statusDetails['color'],
                                    fontSize: isTablet ? 8 : 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile?.name ?? ''} ${profile?.surname ?? ''}',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.employeeId ?? profile?.uid ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile?.position ?? 'Not specified',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
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
                    _buildInfoCard(
                      icon: Icons.badge_outlined,
                      label: 'Employee ID',
                      value: profile?.employeeId ?? profile?.uid ?? '',
                    ),
                    _buildInfoCard(
                      icon: Icons.work_outline,
                      label: 'Position',
                      value: profile?.position ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.business_outlined,
                      label: 'Department',
                      value: profile?.departmentId ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: profile?.email ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: profile?.phone ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.people_outline,
                      label: 'Role',
                      value: profile?.role ?? 'Not specified',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Contact Information Section
                _buildSection(
                  title: 'Contact Information',
                  icon: Icons.contact_mail_outlined,
                  children: [
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: profile?.address ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.location_city_outlined,
                      label: 'City',
                      value: profile?.city ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.public_outlined,
                      label: 'Country',
                      value: profile?.country ?? 'Not specified',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Emergency Contact Section
                _buildSection(
                  title: 'Emergency Contact',
                  icon: Icons.emergency_outlined,
                  children: [
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'Emergency Contact Name',
                      value: profile?.emergencyName ?? 'Not specified',
                    ),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Emergency Contact Phone',
                      value: profile?.emergencyPhone ?? 'Not specified',
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
                                  color:
                                      statusDetails['color'].withOpacity(0.1),
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
                            _getStatusMessage(profile?.verificationStatus),
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

                const SizedBox(height: 32),

                // Action Button - Only show if not verified/approved
                if (profile?.verificationStatus?.toLowerCase() != 'verified' &&
                    profile?.verificationStatus?.toLowerCase() != 'approved')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/selfie', // Update with your selfie route
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

                const SizedBox(height: 40),
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

  Widget _buildInfoCard({
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
