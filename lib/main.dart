import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/core/constants/app_theme.dart';
import 'package:veriwork_mobile/core/services/firebase_auth_service.dart';
import 'package:veriwork_mobile/firebase_options.dart';

// Views
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide FirebaseAuth instance
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),

        // Provide AuthService (this matches your class in firebase_auth_service.dart)
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VeriWork',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.onboarding,
        routes: AppRoutes.routes,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      ),
    );
  }
}
