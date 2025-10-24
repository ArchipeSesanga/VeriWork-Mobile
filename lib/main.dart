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
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (context) => ForgotPassViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VeriWork',
        theme: AppTheme.lightTheme,
        home: StreamBuilder(
          stream: firebaseAuth.authStateChanges(),
          builder: (context, snapshot) {
            // check if user signed in
            if (snapshot.hasData) {
              return const DashboardScreen();
            } else {
              // user not loggedin
              return const OnboardingPage();
            }
          },
        ),
        onGenerateRoute: AppRoutes.routes,
      ),
    );
  }
}
