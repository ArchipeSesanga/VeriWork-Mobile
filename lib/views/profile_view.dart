import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import '../models/profile_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileModel _profile;
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

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

  final _formKey = GlobalKey<FormState>();
  bool _isValidating = false; // Added to trigger re-render

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
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImageBytes = bytes);
        } else {
          setState(() => _mobileImagePath = pickedFile.path);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
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

      final controllers = {
        'name': _nameController,
        'employeeId': _employeeIdController,
        'departmentId': _departmentIdController,
        'email': _emailController,
        'phone': _phoneController,
      };
      final controller = controllers[field];
      if (controller != null) {
        controller.text = value;
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
        backgroundColor: const Color.fromARGB(255, 66, 98, 167),
        title: Center(
          child: Image.asset(
            'assets/app_logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: kIsWeb
                      ? (_webImageBytes != null
                          ? MemoryImage(_webImageBytes!)
                          : const AssetImage('assets/profile_banner.png')
                              as ImageProvider)
                      : (_mobileImagePath != null
                          ? FileImage(File(_mobileImagePath!))
                          : const AssetImage('assets/profile_banner.png')
                              as ImageProvider),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
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
                                      as ImageProvider)
                              : (_mobileImagePath != null
                                  ? FileImage(File(_mobileImagePath!))
                                  : const AssetImage(
                                          'assets/profile_banner.png')
                                      as ImageProvider),
                          onBackgroundImageError: (_, __) =>
                              const AssetImage('assets/profile_banner.png'),
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
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
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
                    setState(() {
                      _isValidating = true; // Trigger re-validation
                    });
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile submitted')),
                      );
                    } else {
                      // Errors should now be visible due to autovalidateMode
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 66, 98, 167),
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
          TextFormField(
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
              errorStyle: const TextStyle(color: Colors.red),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: (value) {
              print('Validating $label: ${value ?? "null"}'); // Debug print
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              if (label == 'Employee ID' && value.length < 3) {
                return 'Employee number must be at least 3 digits';
              }
              if (label == 'Email Address' && !RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              if (label == 'Phone Number' && !RegExp(
                r'^\+27\d{9}$'
              ).hasMatch(value)) {
                return 'Please enter a valid South African phone number (e.g., +27123456789)';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.always,
            selectionControls: MaterialTextSelectionControls(),
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