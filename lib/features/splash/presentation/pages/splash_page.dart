import 'dart:async';

import 'package:bloc_todo/app/routes/app_routes.dart';
import 'package:bloc_todo/gen/assets.gen.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onAnimationStatusChanged);
    _fallbackTimer = Timer(const Duration(seconds: 3), _goHome);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goHome();
    }
  }

  void _goHome() {
    if (!mounted) return;

    _fallbackTimer?.cancel();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Center(
          child: SizedBox.square(
            dimension: 260,
            child: Assets.animations.todoSplashMinimal.lottie(
              controller: _controller,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.checklist_rounded,
                  size: 96,
                  color: AppColors.success,
                );
              },
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          ),
        ),
      ),
    );
  }
}
