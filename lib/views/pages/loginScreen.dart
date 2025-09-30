import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberController = TextEditingController();
  final _saIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _saIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation for Employee Number
  String? _validateEmployeeNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee number is required';
    }
    if (value.length < 3) {
      return 'Employee number must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Employee number can only contain letters and numbers';
    }
    return null;
  }

  // Validation for SA ID Number
  String? _validateSaId(String? value) {
    if (value == null || value.isEmpty) {
      return 'SA ID number is required';
    }
    // Remove any spaces or dashes
    String cleanId = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cleanId.length != 13) {
      return 'SA ID number must be 13 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleanId)) {
      return 'SA ID number can only contain digits';
    }

    // Basic SA ID validation (Luhn algorithm check)
    if (!_isValidSaId(cleanId)) {
      return 'Invalid SA ID number';
    }
    return null;
  }

  // SA ID Luhn algorithm validation
  bool _isValidSaId(String id) {
    if (id.length != 13) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = id.length - 1; i >= 0; i--) {
      int digit = int.parse(id[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // Validation for Password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Handle login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success message (replace with actual login logic)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Handle forgot password
  void _handleForgotPassword() {
    // Add your forgot password logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password functionality coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Back Title
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Employee Number Field
                      TextFormField(
                        controller: _employeeNumberController,
                        decoration: InputDecoration(
                          labelText: 'Employee number',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: _validateEmployeeNumber,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),

                      // SA ID Number Field
                      TextFormField(
                        controller: _saIdController,
                        decoration: InputDecoration(
                          labelText: 'SA ID Number',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.credit_card),
                          hintText: '0000000000000',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        validator: _validateSaId,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 40),

                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2E7D96,
                            ), // Blue color from image
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Forgot Password Link
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text(
                          'Forgot your Password?',
                          style: TextStyle(
                            color: Color(0xFF2E7D96),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
