import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import '../../models/profile_model.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileModel _profile;
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  // Firebase hosted image (default)
  final String firebaseImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/veriwork-database.firebasestorage.app/o/f0e3e68a-d57c-4790-b030-23ef42b2280a_greenp-arrot.jpg?alt=media";

  // Controllers for each field to maintain cursor and focus
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Focus nodes to manage focus
  final _nameFocus = FocusNode();
  final _employeeIdFocus = FocusNode();
  final _departmentIdFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

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
    if (kIsWeb) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImageBytes = bytes);
      }
    } else {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _mobileImagePath = pickedFile.path;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to pick image: $e')));
        }
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

  void _logout() async {
    // Clear any stored authentication data
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.clear(); // or prefs.remove('token') for specific keys

    // Show logout message
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logged out')));

      // Navigate to login screen and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
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
    return Scaffold(
      appBar: CustomAppBar(
        onProfileTap: _logout,
        profileImage: const AssetImage('assets/images/default_profile.png'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Profile & Settings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _getProfileImage(),
                          onBackgroundImageError: (_, __) {},
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: Container(
                            width: 16,
                            height: 16,
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
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile.name ?? '',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _profile.employeeId ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          _buildField(
            label: 'Name',
            controller: _nameController,
            focusNode: _nameFocus,
            onChanged: (value) => _updateField('name', value),
            hintText: 'eg. Jane Doe',
          ),
          _buildField(
            label: 'Employee ID',
            controller: _employeeIdController,
            focusNode: _employeeIdFocus,
            onChanged: (value) => _updateField('employeeId', value),
            hintText: 'eg. EMP-007',
          ),
          _buildField(
            label: 'Department',
            controller: _departmentIdController,
            focusNode: _departmentIdFocus,
            onChanged: (value) => _updateField('departmentId', value),
            hintText: 'eg. Human Resources',
          ),
          _buildField(
            label: 'Email Address',
            controller: _emailController,
            focusNode: _emailFocus,
            onChanged: (value) => _updateField('email', value),
            keyboardType: TextInputType.emailAddress,
            hintText: 'eg. jane.doe@example.com',
          ),
          _buildField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            onChanged: (value) => _updateField('phone', value),
            keyboardType: TextInputType.phone,
            hintText: 'eg. +27 123 456 789',
            hasCheckIcon: false,
          ),
          const SizedBox(height: 24.0),
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
            child: const Text('Submit'),
          ),
          const SizedBox(height: 16.0),
        ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4.0),
          TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: hasCheckIcon
                  ? Icon(Icons.check, color: Colors.grey[400])
                  : null,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
