import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_controller.dart';
import 'design/theme/app_theme.dart';

class NimbusApp extends ConsumerWidget {
  const NimbusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);
    final themeMode = switch (settings.themeMode) {
      NimbusThemeMode.auto => ThemeMode.system,
      NimbusThemeMode.dark => ThemeMode.dark,
      NimbusThemeMode.light => ThemeMode.light,
    };
    return MaterialApp.router(
      title: 'Nimbus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
