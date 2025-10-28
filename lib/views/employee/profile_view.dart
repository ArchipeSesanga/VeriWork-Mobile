import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';
import 'package:veriwork_mobile/widgets/custom_bottom_nav.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileModel _profile;
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  final String firebaseImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/veriwork-database.firebasestorage.app/o/f0e3e68a-d57c-4790-b030-23ef42b2280a_greenp-arrot.jpg?alt=media";

  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _employeeIdFocus = FocusNode();
  final _departmentIdFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  int _selectedIndex = 1; // 0 = Home, 1 = Profile

  @override
  void initState() {
    super.initState();
    _profile = ProfileModel(
      name: '',
      employeeId: '',
      departmentId: '',
      email: '',
      phone: '',
      imageUrl: null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _departmentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _employeeIdFocus.dispose();
    _departmentIdFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _mobileImagePath = pickedFile.path);
      }
    }
  }

  void _updateField(String field, String value) {
    setState(() {
      _profile = _profile.copyWith(
        name: field == 'name' ? value : _profile.name,
        employeeId: field == 'employeeId' ? value : _profile.employeeId,
        departmentId: field == 'departmentId' ? value : _profile.departmentId,
        email: field == 'email' ? value : _profile.email,
        phone: field == 'phone' ? value : _profile.phone,
      );
      final controller = {
        'name': _nameController,
        'employeeId': _employeeIdController,
        'departmentId': _departmentIdController,
        'email': _emailController,
        'phone': _phoneController,
      }[field];
      if (controller != null) {
        controller.text = value;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }

  Future<void> _logout() async {
    print('Profile to Logout to Login');
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    await viewModel.logoutUser(context);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      print('Profile to Dashboard (Bottom Nav)');
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  ImageProvider<Object> _getProfileImage() {
    if (kIsWeb) {
      if (_webImageBytes != null) return MemoryImage(_webImageBytes!);
      return NetworkImage(firebaseImageUrl);
    } else {
      if (_mobileImagePath != null) return FileImage(File(_mobileImagePath!));
      return NetworkImage(firebaseImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final padding = isTablet ? 24.0 : 16.0;
    final textScale = isTablet ? 1.2 : 1.0;

    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap: _logout,
        profileImage: const AssetImage('assets/images/default_profile.png'),
      ),
      body: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          Text(
            'Profile & Settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16 * textScale),

          // Profile Header
          Center(
            child: Container(
              padding: EdgeInsets.all(16 * textScale),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40 * textScale,
                          backgroundImage: _getProfileImage(),
                          onBackgroundImageError: (_, __) {},
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5 * textScale,
                          child: Container(
                            width: 16 * textScale,
                            height: 16 * textScale,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16 * textScale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile.name ?? '',
                          style: TextStyle(
                            fontSize: 22 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _profile.employeeId ?? '',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24 * textScale),

          // Personal Info
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * textScale),

          _buildField(
            label: 'Name',
            controller: _nameController,
            focusNode: _nameFocus,
            onChanged: (v) => _updateField('name', v),
            hintText: 'eg. Jane Doe',
            textScale: textScale,
          ),
          _buildField(
            label: 'Employee ID',
            controller: _employeeIdController,
            focusNode: _employeeIdFocus,
            onChanged: (v) => _updateField('employeeId', v),
            hintText: 'eg. EMP-007',
            textScale: textScale,
          ),
          _buildField(
            label: 'Department',
            controller: _departmentIdController,
            focusNode: _departmentIdFocus,
            onChanged: (v) => _updateField('departmentId', v),
            hintText: 'eg. Human Resources',
            textScale: textScale,
          ),
          _buildField(
            label: 'Email Address',
            controller: _emailController,
            focusNode: _emailFocus,
            onChanged: (v) => _updateField('email', v),
            keyboardType: TextInputType.emailAddress,
            hintText: 'eg. jane.doe@example.com',
            textScale: textScale,
          ),
          _buildField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            onChanged: (v) => _updateField('phone', v),
            keyboardType: TextInputType.phone,
            hintText: 'eg. +27 123 456 789',
            hasCheckIcon: false,
            textScale: textScale,
          ),

          SizedBox(height: 24 * textScale),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile submitted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16 * textScale),
            ),
          ),
          SizedBox(height: 16 * textScale),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    bool hasCheckIcon = false,
    String? hintText,
    required double textScale,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0 * textScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * textScale,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.0 * textScale),
          TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0 * textScale,
                vertical: 12.0 * textScale,
              ),
              suffixIcon: hasCheckIcon
                  ? Icon(Icons.check, color: Colors.grey[400])
                  : null,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
                fontSize: 14 * textScale,
              ),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(fontSize: 15 * textScale),
          ),
        ],
      ),
    );
  }
}
