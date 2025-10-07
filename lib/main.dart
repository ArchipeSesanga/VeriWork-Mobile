import 'package:flutter/material.dart';
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
      initialRoute: '/profile & Settings',  // Launch directly to ProfileView
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        // '/Dashboard': (context) => DashboardView(),
        '/profile & Settings': (context) => const ProfileView(),
        
      },
      theme: ThemeData(primarySwatch: Colors.blue),
      // Removed 'home' to avoid conflict with initialRoute
    );
  }
}
