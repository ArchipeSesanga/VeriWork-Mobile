import 'package:flutter/material.dart';
import 'package:veriwork_mobile/views/employee/dashboard_view.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart';
import 'package:veriwork_mobile/views/pages/verification_pending.dart';

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

      // Set initial route - change this based on your needs
      initialRoute: '/', // Start with onboarding, or '/login' for direct login

      // Define all app routes
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileView(),
        '/selfie': (context) => const SelfiePage(),
        '/verification_pending': (context) => const VerificationPendingScreen(),
      },

      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        );
      },

      // App theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,

        // Customize colors to match your design
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        // Typography ok
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
        ),

        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
