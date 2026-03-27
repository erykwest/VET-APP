import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'config/app_bootstrap_state.dart';

class VetApp extends StatelessWidget {
  const VetApp({super.key, required this.bootstrapState});

  final AppBootstrapState bootstrapState;

  @override
  Widget build(BuildContext context) {
    final initialRoute = bootstrapState.shouldBypassAuth
        ? AppRouter.splash
        : bootstrapState.previewMode
            ? AppRouter.previewDashboard
            : AppRouter.splash;

    return MaterialApp(
      title: 'VET APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, bootstrapState: bootstrapState),
    );
  }
}
