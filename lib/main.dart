import 'package:flutter/material.dart';
import 'package:veriwork_mobile/views/employee/verification_pending_view.dart';
import 'package:veriwork_mobile/views/employee/verification_successful_view.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onboarding Demo',
      initialRoute: '/verification_successful',  // Launch directly to VerificationSuccessfulView
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        // '/Dashboard': (context) => DashboardView(),
        '/profile & Settings': (context) => const ProfileView(),
        '/verification_pending': (context) => const VerificationPendingView(),
        '/verification_successful': (context) => const VerificationSuccessfulView(),
        
      },
      theme: ThemeData(primarySwatch: Colors.blue),
      // Removed 'home' to avoid conflict with initialRoute
    );
  }
}
