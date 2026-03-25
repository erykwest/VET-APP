import 'package:flutter/material.dart';

import '../../auth/presentation/pages/auth_placeholder_page.dart';
import 'pages/onboarding_privacy_disclaimer_page.dart';
import 'pages/onboarding_value_proposition_page.dart';

class OnboardingRoutes {
  static Route<void> valueProposition() {
    return MaterialPageRoute<void>(
      builder: (_) => const OnboardingValuePropositionPage(),
    );
  }

  static Route<void> privacyDisclaimer() {
    return MaterialPageRoute<void>(
      builder: (_) => const OnboardingPrivacyDisclaimerPage(),
    );
  }

  static Route<void> authHub() {
    return MaterialPageRoute<void>(
      builder: (_) => const AuthPlaceholderPage(),
    );
  }
}
