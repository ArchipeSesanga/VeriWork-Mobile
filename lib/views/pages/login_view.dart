import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/utils/validators.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/forgot_pass_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        print('Login to Back to Welcome');
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final paddingHorizontal = isWide ? 48.0 : 24.0;
          final paddingVertical = isWide ? 24.0 : 16.0;
          final titleFontSize = isWide ? 30.0 : 24.0;
          final fieldSpacing = isWide ? 20.0 : 16.0;
          final formRadius = isWide ? 50.0 : 40.0;

          return Scaffold(
            key: viewModel.scaffoldKey,
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
                          key: viewModel.formKey,
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

                              if (_errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (_errorMessage != null)
                                SizedBox(height: fieldSpacing),

                              // Email Field
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: UnderlineInputBorder(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validations.validateEmail,
                                textInputAction: TextInputAction.next,
                                onSaved: (value) => viewModel.setEmail(value),
                              ),
                              SizedBox(height: fieldSpacing),

                              // Password
                              TextFormField(
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
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                validator: Validations.validatePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    viewModel.login(context),
                                onSaved: (value) =>
                                    viewModel.setPassword(value),
                              ),
                              SizedBox(height: isWide ? 30 : 24),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: size.height * 0.065,
                                child: ElevatedButton(
                                  onPressed: viewModel.loading
                                      ? null
                                      : () {
                                          if (viewModel.formKey.currentState!
                                              .validate()) {
                                            viewModel.formKey.currentState!
                                                .save();
                                            print(
                                              'Login to Attempting login...',
                                            );
                                            viewModel.login(context);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: viewModel.loading
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
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isWide ? 16 : 12),

                              // Forgot Password
                              TextButton(
                                onPressed: () =>
                                    _showForgotPasswordDialog(context),
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
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final viewModel = Provider.of<ForgotPassViewModel>(
          context,
          listen: false,
        );

        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to reset your password:'),
              const SizedBox(height: 16),
              Form(
                key: viewModel.formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validations.validateEmail,
                  onSaved: (value) => viewModel.setEmail(value),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: viewModel.loading
                  ? null
                  : () {
                      if (viewModel.formKey.currentState!.validate()) {
                        viewModel.formKey.currentState!.save();
                        print('Forgot Password to Sending reset link...');
                        viewModel.forgotPassword(context);
                      }
                    },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }
}
