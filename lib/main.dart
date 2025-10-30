import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/core/constants/app_theme.dart';
import 'package:veriwork_mobile/firebase_options.dart';
import 'package:veriwork_mobile/core/utils/firebase.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/forgot_pass_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/auth_viewmodels/login_viewmodel.dart';
import 'package:veriwork_mobile/viewmodels/dashboard_viewmodel.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';

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
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VeriWork',
        theme: AppTheme.lightTheme,
        home: FutureBuilder(
          // Wait for Firebase to be fully initialized
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Firebase Error: ${snapshot.error}'),
                ),
              );
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder(
                stream: firebaseAuth.authStateChanges(),
                builder: (context, snapshot) {
                  // Check if user is signed in
                  if (snapshot.hasData) {
                    return const DashboardScreen();
                  } else {
                    // User not logged in
                    return const LoginScreen();
                  }
                },
              );
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        onGenerateRoute: AppRoutes.routes,
      ),
    );
  }
}
