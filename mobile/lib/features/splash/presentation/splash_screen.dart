import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(0, -70),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -9 * math.pi / 180,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkText.withValues(alpha: 0.10),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                size: 82,
                                color: AppColors.white,
                              ),
                              Transform.translate(
                                offset: const Offset(20, -14),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentOrange,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(
                                      BorderSide(color: AppColors.white, width: 4),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.bolt,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(36),
                    const Text(
                      'QuickBite',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      'DELIVERED FAST',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.52),
              child: SizedBox(
                width: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    value: 0.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    backgroundColor: AppColors.gray200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
