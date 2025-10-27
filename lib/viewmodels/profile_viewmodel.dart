import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

enum ProfileState { initial, loading, loaded, error, updating }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  ProfileModel? _profile;
  ProfileState _state = ProfileState.initial;
  String? _errorMessage;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  // Getters
  ProfileModel? get profile => _profile;
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  File? get selectedImageFile => _selectedImageFile;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  bool get isLoading => _state == ProfileState.loading;
  bool get isUpdating => _state == ProfileState.updating;
  bool get hasError => _state == ProfileState.error;

  // Check if profile has unsaved changes
  bool get hasUnsavedChanges =>
      _selectedImageFile != null || _selectedImageBytes != null;

  // Set profile data
  void setProfile(ProfileModel profile) {
    _profile = profile;
    _state = ProfileState.loaded;
    notifyListeners();
  }

  // Load profile
  Future<void> loadProfile(String userId) async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _repository.getUserProfile(userId);
      if (profile != null) {
        _profile = profile;
        _state = ProfileState.loaded;
      } else {
        _errorMessage = 'Profile not found';
        _state = ProfileState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.error;
    }
    notifyListeners();
  }

  // Listen to profile changes (real-time)
  Stream<ProfileModel?> profileStream(String userId) {
    return _repository.getUserProfileStream(userId);
  }

  // Set selected image
  void setSelectedImage({File? imageFile, Uint8List? imageBytes}) {
    _selectedImageFile = imageFile;
    _selectedImageBytes = imageBytes;
    notifyListeners();
  }

  // Clear selected image
  void clearSelectedImage() {
    _selectedImageFile = null;
    _selectedImageBytes = null;
    notifyListeners();
  }

  // Update profile field locally (for real-time UI updates)
  void updateFieldLocally(String field, dynamic value) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      name: field == 'name' ? value : _profile!.name,
      surname: field == 'surname' ? value : _profile!.surname,
      email: field == 'email' ? value : _profile!.email,
      phone: field == 'phone' ? value : _profile!.phone,
      address: field == 'address' ? value : _profile!.address,
      departmentId: field == 'departmentId' ? value : _profile!.departmentId,
      position: field == 'position' ? value : _profile!.position,
    );
    notifyListeners();
  }

  // Save profile updates to Firebase
  Future<bool> saveProfile(String userId) async {
    if (_profile == null) return false;

    _state = ProfileState.updating;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};

      // Add fields to update
      if (_profile!.name != null) updates['Name'] = _profile!.name;
      if (_profile!.surname != null) updates['Surname'] = _profile!.surname;
      if (_profile!.email != null) updates['Email'] = _profile!.email;
      if (_profile!.phone != null) updates['Phone'] = _profile!.phone;
      if (_profile!.address != null) updates['Address'] = _profile!.address;
      if (_profile!.departmentId != null) {
        updates['DepartmentId'] = _profile!.departmentId;
      }
      if (_profile!.position != null) updates['Position'] = _profile!.position;

      // Upload profile with photo if image is selected
      if (_selectedImageFile != null || _selectedImageBytes != null) {
        await _repository.updateProfileWithPhoto(
          userId: userId,
          profileData: updates,
          imageFile: _selectedImageFile,
          imageBytes: _selectedImageBytes,
        );
        // Clear selected image after successful upload
        clearSelectedImage();
      } else {
        // Update without photo
        await _repository.updateProfile(userId: userId, updates: updates);
      }

      _state = ProfileState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.error;
      notifyListeners();
      return false;
    }
  }

  // Update specific fields
  Future<bool> updateName(String userId, String name, String surname) async {
    try {
      await _repository.updateName(userId, name, surname);
      if (_profile != null) {
        _profile = _profile!.copyWith(name: name, surname: surname);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateEmail(String userId, String email) async {
    try {
      await _repository.updateEmail(userId, email);
      if (_profile != null) {
        _profile = _profile!.copyWith(email: email);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updatePhone(String userId, String phone) async {
    try {
      await _repository.updatePhone(userId, phone);
      if (_profile != null) {
        _profile = _profile!.copyWith(phone: phone);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateAddress(String userId, String address) async {
    try {
      await _repository.updateAddress(userId, address);
      if (_profile != null) {
        _profile = _profile!.copyWith(address: address);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // Reset state
  void reset() {
    _profile = null;
    _state = ProfileState.initial;
    _errorMessage = null;
    _selectedImageFile = null;
    _selectedImageBytes = null;
    notifyListeners();
  }
}
