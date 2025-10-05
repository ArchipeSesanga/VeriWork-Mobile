import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:veriwork_mobile/views/pages/loginScreen.dart';
=======
import 'package:veriwork_mobile/views/pages/loginscreen.dart';
>>>>>>> Stashed changes
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        // '/profile': (context) => ProfileScreen(),
        // '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
