import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';

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

  String? _validateEmployeeNumber(String? value) {
    if (value == null || value.isEmpty) return 'Employee number is required';
    if (value.length < 3) {
      return 'Employee number must be at least 3 characters';
    }
    return null;
  }

  String? _validateSaId(String? value) {
    if (value == null || value.isEmpty) return 'SA ID number is required';
    if (value.length != 13) return 'SA ID number must be 13 digits';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final paddingHorizontal = isWide ? 48.0 : 24.0;
        final paddingVertical = isWide ? 24.0 : 16.0;
        final titleFontSize = isWide ? 30.0 : 24.0;
        final fieldSpacing = isWide ? 20.0 : 16.0;
        final formRadius = isWide ? 50.0 : 40.0;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(formRadius),
                      topRight: Radius.circular(formRadius),
                    ),
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: isWide ? 20 : 12),
                            Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: isWide ? 30 : 24),

                            // Employee Number
                            TextFormField(
                              controller: _employeeNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Employee number',
                                border: UnderlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: _validateEmployeeNumber,
                            ),
                            SizedBox(height: fieldSpacing),

                            // SA ID Number
                            TextFormField(
                              controller: _saIdController,
                              decoration: const InputDecoration(
                                labelText: 'SA ID Number',
                                border: UnderlineInputBorder(),
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                              validator: _validateSaId,
                            ),
                            SizedBox(height: fieldSpacing),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const UnderlineInputBorder(),
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
                            ),
                            SizedBox(height: isWide ? 30 : 24),

                            // ✅ Fixed Login Button
                            SizedBox(
                              width: double.infinity,
                              height: size.height * 0.065,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                  padding: EdgeInsets.zero,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(height: isWide ? 16 : 12),

                            // Forgot Password
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot your Password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
