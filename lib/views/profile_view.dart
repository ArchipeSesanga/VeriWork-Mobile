import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      name: 'Jane Doe',
      employeeId: 'EMP-007',
      departmentId: 'DEPT-001',
      email: 'jane.doe@example.com',
      phone: '+1 (555) 123-4567',
      imageUrl: null,
    );
    // Initialize controllers with initial values
    _nameController.text = _profile.name ?? '';
    _employeeIdController.text = _profile.employeeId ?? '';
    _departmentIdController.text = _profile.departmentId ?? '';
    _emailController.text = _profile.email ?? '';
    _phoneController.text = _profile.phone ?? '';
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
      final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      await input.onChange.first;
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final arrayBuffer = reader.result as Uint8List;
        setState(() {
          _webImageBytes = arrayBuffer;
        });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
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
    });
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  void _navigateHome() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to Home')));
  }

  void _navigateProfile() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already on Profile')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Profile Details',
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
                                  : const AssetImage('assets/profile_banner.png'))
                              : (_mobileImagePath != null
                                  ? FileImage(File(_mobileImagePath!))
                                  : const AssetImage('assets/profile_banner.png')),
                          onBackgroundImageError: (_, __) => const AssetImage('assets/profile_banner.png'),
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
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          ),
          _buildField(
            label: 'Employee ID',
            controller: _employeeIdController,
            focusNode: _employeeIdFocus,
            onChanged: (value) => _updateField('employeeId', value),
          ),
          _buildField(
            label: 'Department',
            controller: _departmentIdController,
            focusNode: _departmentIdFocus,
            onChanged: (value) => _updateField('departmentId', value),
          ),
          _buildField(
            label: 'Email Address',
            controller: _emailController,
            focusNode: _emailFocus,
            onChanged: (value) => _updateField('email', value),
            keyboardType: TextInputType.emailAddress,
          ),
          _buildField(
            label: 'Phone',
            controller: _phoneController,
            focusNode: _phoneFocus,
            onChanged: (value) => _updateField('phone', value),
            keyboardType: TextInputType.phone,
            hasCheckIcon: true,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: hasCheckIcon ? Icon(Icons.check, color: Colors.grey[400]) : null,
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}