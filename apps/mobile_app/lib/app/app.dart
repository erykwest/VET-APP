import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
    final initialRoute = !bootstrapState.supabaseEnabled && kIsWeb
        ? AppRouter.previewDashboard
        : AppRouter.splash;

    return MaterialApp(
      title: 'VET APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        final body = child ?? const SizedBox.shrink();
        if (bootstrapState.supabaseEnabled) {
          return body;
        }

        return Banner(
          message: kIsWeb ? 'WEB PREVIEW' : 'PREVIEW',
          location: BannerLocation.topEnd,
          child: body,
        );
      },
    );
  }
}
