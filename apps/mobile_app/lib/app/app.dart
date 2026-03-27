import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'config/app_bootstrap_state.dart';

class VetApp extends StatelessWidget {
  const VetApp({
    super.key,
    required this.bootstrapState,
  });

  final AppBootstrapState bootstrapState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VET APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRouter.splash,
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, bootstrapState: bootstrapState),
    );
  }
}
