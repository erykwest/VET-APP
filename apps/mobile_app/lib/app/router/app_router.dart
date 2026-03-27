import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/auth_placeholder_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import '../../features/pets/presentation/pages/pet_public_card_page.dart';
import '../config/app_bootstrap_state.dart';
import '../preview/preview_dashboard_page.dart';
import '../shell/home_shell_page.dart';
import '../splash/splash_page.dart';

class AppRouter {
  static const splash = '/';
  static const onboardingWelcome = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';
  static const homeShell = '/home-shell';
  static const previewDashboard = '/preview-dashboard';
  static const petPublicCard = '/pet-public-card';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    AppBootstrapState? bootstrapState,
  }) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          builder: (_) => SplashPage(
            bootstrapState: bootstrapState,
          ),
          settings: settings,
        );
      case onboardingWelcome:
        return MaterialPageRoute<void>(
          builder: (_) => const OnboardingWelcomePage(),
          settings: settings,
        );
      case auth:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case home:
      case homeShell:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShellPage(),
          settings: settings,
        );
      case previewDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const PreviewDashboardPage(),
          settings: settings,
        );
      case petPublicCard:
        final petId = settings.arguments as String?;
        return MaterialPageRoute<void>(
          builder: (_) => PetPublicCardPage(petId: petId),
          settings: settings,
        );
      case '/auth-hub':
        return MaterialPageRoute<void>(
          builder: (_) => const AuthPlaceholderPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => SplashPage(
            bootstrapState: bootstrapState,
          ),
          settings: settings,
        );
    }
  }
}
