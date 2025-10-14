import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:veriwork_mobile/views/employee/dashboard_view.dart';

// Fixed conditional import (use relative paths from lib/views/employee/ to lib/utils/)
// ignore: unused_import
import '../../utils/image_picker_web.dart'
    if (dart.library.html) '../../utils/image_picker_web.dart'
    if (dart.library.io) '../../utils/image_picker_mobile.dart';

import '../../models/profile_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileModel _profile;
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

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
    // Initialize controllers with empty values (hint text will guide)
    _nameController.text = '';
    _employeeIdController.text = '';
    _departmentIdController.text = '';
    _emailController.text = '';
    _phoneController.text = '';
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
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
      // Web image picker using ImagePicker
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
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
      // Update the corresponding controller with the new value
      if (field == 'name') _nameController.text = value;
      if (field == 'employeeId') _employeeIdController.text = value;
      if (field == 'departmentId') _departmentIdController.text = value;
      if (field == 'email') _emailController.text = value;
      if (field == 'phone') _phoneController.text = value;
      // Set cursor to the end to avoid selection
      final controller = {
        'name': _nameController,
        'employeeId': _employeeIdController,
        'departmentId': _departmentIdController,
        'email': _emailController,
        'phone': _phoneController,
      }[field];
      if (controller != null) {
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }

  void _logout() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  void _navigateHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _navigateProfile() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Already on Profile')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Center(
          child: Image.asset(
            'assets/images/Logo.png', // Replace with your logo file name
            height: 40, // Adjust height as needed
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 20, // Smaller radius for app bar
                  backgroundImage: kIsWeb
                      ? (_webImageBytes != null
                          ? MemoryImage(_webImageBytes!)
                          : const AssetImage('assets/profile_banner.png')
                              as ImageProvider<Object>)
                      : (_mobileImagePath != null
                          ? FileImage(File(_mobileImagePath!))
                          : const AssetImage('assets/profile_banner.png')
                              as ImageProvider<Object>),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ],
          ),
        ],
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
                          backgroundImage: kIsWeb
                              ? (_webImageBytes != null
                                  ? MemoryImage(_webImageBytes!)
                                  : const AssetImage(
                                          'assets/profile_banner.png')
                                      as ImageProvider<Object>)
                              : (_mobileImagePath != null
                                  ? FileImage(File(_mobileImagePath!))
                                  : const AssetImage(
                                          'assets/profile_banner.png')
                                      as ImageProvider<Object>),
                          onBackgroundImageError: (_, __) =>
                              const AssetImage('assets/profile_banner.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2)),
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
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('Submit'),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: _navigateHome,
                    tooltip: 'Home',
                  ),
                  const Text('Home'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: _navigateProfile,
                    tooltip: 'Profile',
                  ),
                  const Text('Profile'),
                ],
              ),
            ],
          ),
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
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
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
            selectionControls: MaterialTextSelectionControls(),
            enableInteractiveSelection: true,
            onTap: () {
              if (controller.selection.isCollapsed) {
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.selection.baseOffset),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
