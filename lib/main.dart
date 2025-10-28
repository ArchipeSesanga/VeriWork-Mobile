import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/core/constants/app_theme.dart';
import 'package:veriwork_mobile/firebase_options.dart';
import 'package:veriwork_mobile/core/utils/firebase.dart';

import 'package:veriwork_mobile/viewmodels/auth_viewmodels/forgot_pass_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';

import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
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
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPassViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VeriWork',
        theme: AppTheme.lightTheme,

        // ---- NAMED ROUTES ----
        initialRoute: AppRoutes.onboarding,           // first screen for new users
        onGenerateRoute: AppRoutes.generateRoute,    // <-- uses the switch in routes.dart

        // ---- AUTH FLOW (no route needed here) ----
        home: StreamBuilder(
          stream: firebaseAuth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // User is signed in → go straight to Dashboard
              return const DashboardScreen();
            }
            // Not signed in → start the onboarding flow
            return const OnboardingPage();
          },
        ),
      ),
    );
  }
}