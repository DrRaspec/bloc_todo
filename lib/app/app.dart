import 'package:bloc_todo/app/routes/app_router.dart';
import 'package:bloc_todo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_bridge/liquid_glass_bridge.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassTheme(
      data: LiquidGlassThemeData(
        style: LiquidGlassPresets.ios28,
        mode: LiquidGlassMode.auto,
        quality: LiquidGlassQuality.medium,
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
