import 'package:flutter/material.dart';

import 'package:veriwork_mobile/views/employee/profile_view.dart';
import 'package:veriwork_mobile/views/employee/verification_pending_view.dart';
import 'package:veriwork_mobile/views/employee/verification_rejected.dart';
import 'package:veriwork_mobile/views/employee/verification_successful_view.dart';
import 'package:veriwork_mobile/views/pages/dashboard_screen.dart';
import 'package:veriwork_mobile/views/pages/login_screen.dart';
import 'package:veriwork_mobile/views/pages/onboarding_page.dart';
import 'package:veriwork_mobile/views/pages/welcome_page.dart';
import 'package:veriwork_mobile/views/pages/selfie_verification_page.dart';

class AppRoutes {
  // ── ROUTE NAMES ─────────────────────────────────────────────────────
  static const String onboarding = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profileSettings = '/profile_settings';
  static const String verificationPending = '/verification_pending';
  static const String verificationSuccessful = '/verification_successful';
  static const String verificationRejected = '/verification_rejected';
  static const String selfie = '/selfie';

  static RouteFactory? get routes => null;

  // ── ROUTE BUILDER ───────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return _page(const OnboardingPage());
      case welcome:
        return _page(const WelcomeScreen());
      case login:
        return _page(const LoginScreen());
      case dashboard:
        return _page(const DashboardScreen());
      case profileSettings:
        return _page(const ProfileView());
      case verificationPending:
        return _page(const VerificationPendingView());
      case verificationSuccessful:
        return _page(const VerificationSuccessfulView());
      case verificationRejected:
        return _page(const VerificationRejectedView());
      case selfie:
        return _page(const SelfiePage());

      default:
        // Fallback – never hit if you use the constants
        return _page(const OnboardingPage());
    }
  }

  // Helper – keeps the switch clean
  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
