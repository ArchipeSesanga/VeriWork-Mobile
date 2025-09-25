import 'package:flutter/material.dart';
import 'screens/LoginScreen.dart';

void main() {
  runApp(VeriworkMobileApp());
}

class VeriworkMobileApp extends StatelessWidget {
  VeriworkMobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veriwork Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF3B5998),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),

        // '/home': (context) => const HomePage(),
        // '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
