import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
=======
import 'views/profile_view.dart';
>>>>>>> Sibu-branch

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'Onboarding Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/login': (context) => const LoginScreen(),
        // '/profile': (context) => ProfileScreen(),
        // '/settings': (context) => SettingsScreen(),
      },
=======
      title: 'VeriWork System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProfileView(),
>>>>>>> Sibu-branch
    );
  }
}
