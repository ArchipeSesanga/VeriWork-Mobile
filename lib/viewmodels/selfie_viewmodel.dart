import 'package:flutter/material.dart';
import 'dart:io';
import 'package:veriwork_mobile/core/services/firebase_selfie_service.dart';

class SelfieViewModel extends ChangeNotifier {
  final SelfieService _selfieService = SelfieService();

  bool _isLoading = false;
  String? _errorMessage;
  File? _selfieFile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selfieFile => _selfieFile;

  void setSelfieFile(File file) {
    _selfieFile = file;
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> uploadSelfie() async {
    if (_selfieFile == null) {
      _errorMessage = "Please capture a selfie first";
      notifyListeners();
      throw Exception(_errorMessage);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call Azure Face API
      final response = await _selfieService.uploadSelfie(_selfieFile!);

      _isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _selfieFile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
