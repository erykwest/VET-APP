import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class VetApp extends StatelessWidget {
  const VetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VET APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
