import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _slides = <({String title, String description, String imageUrl})>[
    (
      title: 'Editorial Taste,\nDelivered to Your Door.',
      description:
          'Experience a curated selection of the city\'s finest culinary gems, delivered with frictionless precision.',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1661526833843-248a2f8fe129?auto=format&fit=crop&w=800&q=80',
    ),
    (
      title: 'Build Your Perfect Cart\nIn Seconds.',
      description:
          'Add favorites in one tap, keep totals clear, and move from browsing to checkout without friction.',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    ),
    (
      title: 'Track Every Step\nFrom Kitchen to Door.',
      description:
          'Get live status updates from confirmation to delivery and know exactly when your order arrives.',
      imageUrl:
          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLast = _index == _slides.length - 1;
    final slide = _slides[_index];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final page = _slides[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 55,
                        child: Container(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.16,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Transform.rotate(
                              angle: 0.08,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    page.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: colorScheme.surfaceContainerHigh,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: colorScheme.onSurfaceVariant,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(flex: 45, child: SizedBox.shrink()),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                ),
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Skip',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Text(
                      slide.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Row(
                      children: List.generate(
                        _slides.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: _index == dotIndex ? 24 : 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _index == dotIndex
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (isLast) {
                            context.go('/home');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        label: Text(isLast ? 'Get Started' : 'Next'),
                        icon: const Icon(Icons.arrow_forward),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
