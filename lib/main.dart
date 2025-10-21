import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/constants/app_colours.dart';
import 'package:veriwork_mobile/views/employee/verification_pending_view.dart';
import 'package:veriwork_mobile/views/employee/verification_rejected.dart';
import 'package:veriwork_mobile/views/employee/verification_successful_view.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VeriWork',
      initialRoute: '/verification_rejected',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile_settings': (context) => const ProfileView(),
        '/verification_pending': (context) => const VerificationPendingView(),
        '/verification_successful': (context) =>
            const VerificationSuccessfulView(),
        '/verification_rejected': (context) => const VerificationRejectedView(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.primary),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
