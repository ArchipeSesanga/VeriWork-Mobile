import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/models/profile_model.dart';
import 'package:veriwork_mobile/viewmodels/profile_viewmodel.dart';
import 'package:veriwork_mobile/widgets/custom_appbar.dart';

class ProfileView extends StatefulWidget {
  final String? employeeId;

  const ProfileView({super.key, this.employeeId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final String _userId;
  late final ProfileViewModel _viewModel;

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _nameFocus = FocusNode();
  final _surnameFocus = FocusNode();
  final _employeeIdFocus = FocusNode();
  final _departmentFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _userId = widget.employeeId ?? FirebaseAuth.instance.currentUser!.uid;
    _viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _viewModel.loadProfile(_userId);
    _populateControllers();
  }

  void _populateControllers() {
    final profile = _viewModel.profile;
    if (profile != null) {
      _nameController.text = profile.name ?? '';
      _surnameController.text = profile.surname ?? '';
      _employeeIdController.text = profile.employeeId ?? '';
      _departmentController.text = profile.departmentId ?? '';
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _surnameFocus.dispose();
    _employeeIdFocus.dispose();
    _departmentFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          _viewModel.setSelectedImage(imageBytes: bytes);
        } else {
          _viewModel.setSelectedImage(imageFile: File(pickedFile.path));
        }
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _saveProfile() async {
    _viewModel.updateFieldLocally('name', _nameController.text);
    _viewModel.updateFieldLocally('surname', _surnameController.text);
    _viewModel.updateFieldLocally('email', _emailController.text);
    _viewModel.updateFieldLocally('phone', _phoneController.text);
    _viewModel.updateFieldLocally('address', _addressController.text);

    final success = await _viewModel.saveProfile(_userId);

    if (success) {
      _showSnackBar('Profile updated successfully!');
    } else {
      _showSnackBar(
        _viewModel.errorMessage ?? 'Failed to update profile',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateHome() {
    //Navigator.pushReplacement(
    //context,
    //MaterialPageRoute(builder: (context) => DashboardScreen(employeeId: _userId)),
    //);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final profile = viewModel.profile;

        // Loading state
        if (viewModel.isLoading) {
          return Scaffold(
            appBar: CustomAppBar(
              profileImage:
                  const AssetImage('assets/images/default_profile.png'),
              onProfileTap: _pickImage,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (viewModel.hasError && profile == null) {
          return Scaffold(
            appBar: CustomAppBar(
              profileImage:
                  const AssetImage('assets/images/default_profile.png'),
              onProfileTap: _pickImage,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'Failed to load profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Normal state
        return Scaffold(
          appBar: CustomAppBar(
            profileImage: _getAppBarImage(viewModel),
            onProfileTap: _pickImage,
          ),
          body: Stack(
            children: [
              _buildBody(viewModel),
              if (viewModel.isUpdating)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider _getAppBarImage(ProfileViewModel viewModel) {
    if (viewModel.selectedImageFile != null ||
        viewModel.selectedImageBytes != null) {
      return kIsWeb
          ? MemoryImage(viewModel.selectedImageBytes!)
          : FileImage(viewModel.selectedImageFile!) as ImageProvider;
    }

    final profile = viewModel.profile;
    if (profile?.imageUrl != null) {
      return CachedNetworkImageProvider(profile!.imageUrl!);
    }

    // Fallback avatar
    return const AssetImage('assets/images/default_profile.png');
  }

  Widget _buildBody(ProfileViewModel viewModel) {
    final profile = viewModel.profile;
    if (profile == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Profile & Settings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          _buildProfileHeader(viewModel, profile),
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
              hintText: 'eg. Jane'),
          _buildField(
              label: 'Surname',
              controller: _surnameController,
              focusNode: _surnameFocus,
              hintText: 'eg. Doe'),
          _buildField(
              label: 'Employee ID',
              controller: _employeeIdController,
              focusNode: _employeeIdFocus,
              hintText: 'eg. EMP-007',
              enabled: false),
          _buildField(
              label: 'Department',
              controller: _departmentController,
              focusNode: _departmentFocus,
              hintText: 'eg. Human Resources',
              enabled: false),
          _buildField(
              label: 'Email Address',
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              hintText: 'eg. jane.doe@example.com'),
          _buildField(
              label: 'Phone Number',
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              hintText: 'eg. +27 123 456 789'),
          _buildField(
              label: 'Address',
              controller: _addressController,
              focusNode: _addressFocus,
              hintText: 'eg. 123 Main Street, City',
              maxLines: 2),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: viewModel.isUpdating ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: viewModel.isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Changes'),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton(Icons.home, 'Home', _navigateHome),
              _buildNavButton(Icons.person, 'Profile', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel, ProfileModel profile) {
    final hasImage = profile.imageUrl != null;
    final hasSelectedImage = viewModel.selectedImageFile != null ||
        viewModel.selectedImageBytes != null;

    return Center(
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
                    backgroundImage: hasSelectedImage
                        ? (kIsWeb
                            ? MemoryImage(viewModel.selectedImageBytes!)
                                as ImageProvider
                            : FileImage(viewModel.selectedImageFile!)
                                as ImageProvider)
                        : hasImage
                            ? CachedNetworkImageProvider(profile.imageUrl!)
                                as ImageProvider
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider,
                    child: !hasImage && !hasSelectedImage
                        ? Text(
                            _getInitials(profile.name, profile.surname),
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                  if (profile.isVerified == true)
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.name ?? ''} ${profile.surname ?? ''}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(profile.employeeId ?? '',
                      style: TextStyle(color: Colors.grey[600])),
                  if (profile.position != null)
                    Text(profile.position!,
                        style:
                            TextStyle(color: Colors.grey[700], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? name, String? surname) {
    final nameInitial = name?.isNotEmpty == true ? name![0].toUpperCase() : '';
    final surnameInitial =
        surname?.isNotEmpty == true ? surname![0].toUpperCase() : '';
    return '$nameInitial$surnameInitial';
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType? keyboardType,
    String? hintText,
    bool enabled = true,
    int maxLines = 1,
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
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              hintText: hintText,
              hintStyle: TextStyle(
                  color: Colors.grey[400], fontStyle: FontStyle.italic),
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey[100],
            ),
            keyboardType: keyboardType,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback? onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: onTap, tooltip: label),
        Text(label),
      ],
    );
  }
}
