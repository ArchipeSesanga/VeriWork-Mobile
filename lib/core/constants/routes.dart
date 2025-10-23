import 'package:flutter/material.dart';
import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/employee/verification_pending_view.dart';
import 'package:veriwork_mobile/views/employee/verification_rejected.dart';
import 'package:veriwork_mobile/views/employee/verification_successful_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profileSettings = '/profile_settings';
  static const String verificationPending = '/verification_pending';
  static const String verificationSuccessful = '/verification_successful';
  static const String verificationRejected = '/verification_rejected';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingPage(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    profileSettings: (context) => const ProfileView(),
    verificationPending: (context) => const VerificationPendingView(),
    verificationSuccessful: (context) => const VerificationSuccessfulView(),
    verificationRejected: (context) => const VerificationRejectedView(),
  };
}
