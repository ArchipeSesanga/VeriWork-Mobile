import 'package:flutter/material.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/employee/verification_pending_view.dart';
import 'package:veriwork_mobile/views/employee/verification_rejected.dart';
import 'package:veriwork_mobile/views/employee/verification_successful_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
import 'package:veriwork_mobile/views/pages/welcome_page.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart'; // Adjust path as needed

class AppRoutes {
  static const String onboarding = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profileSettings = '/profile_settings';
  static const String verificationPending = '/verification_pending';
  static const String verificationSuccessful = '/verification_successful';
  static const String verificationRejected = '/verification_rejected';
  static const String selfie = '/selfie'; // Ensure this is defined

  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        );
      case welcome:
        return MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        );
      case profileSettings:
        return MaterialPageRoute(
          builder: (context) => const ProfileView(),
        );
      case verificationPending:
        return MaterialPageRoute(
          builder: (context) => const VerificationPendingView(),
        );
      case verificationSuccessful:
        return MaterialPageRoute(
          builder: (context) => const VerificationSuccessfulView(),
        );
      case verificationRejected:
        return MaterialPageRoute(
          builder: (context) => const VerificationRejectedView(),
        );
      case selfie:
        return MaterialPageRoute(
          builder: (context) => const SelfiePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        );
    }
  }
}
