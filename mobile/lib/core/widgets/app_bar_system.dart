import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile/core/constants/app_colors.dart';

class QuickBiteAppBars {
  const QuickBiteAppBars._();

  static PreferredSizeWidget home({
    required String locationLabel,
    required int cartCount,
    required VoidCallback onCartTap,
    VoidCallback? onLocationTap,
  }) {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: InkWell(
        onTap: onLocationTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QuickBite',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 13,
                  color: AppColors.accentOrange,
                ),
                const Gap(2),
                Text(
                  locationLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: onCartTap,
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (cartCount > 0)
              Positioned(
                right: 9,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Gap(6),
      ],
    );
  }

  static PreferredSizeWidget search({
    required VoidCallback onBack,
    required VoidCallback onFilterTap,
    String hintText = 'Search dishes or restaurants...',
  }) {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
      ),
      titleSpacing: 0,
      title: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.outline),
            const Gap(8),
            Expanded(
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.outline, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: onFilterTap,
          icon: const Icon(Icons.tune_rounded),
        ),
        const Gap(4),
      ],
    );
  }

  static PreferredSizeWidget contextual({
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    Widget? trailing,
  }) {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: onBack == null
          ? null
          : IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.accentOrange,
              ),
            ),
        ],
      ),
      actions: [if (trailing != null) trailing, const Gap(8)],
    );
  }

  static PreferredSizeWidget checkout({
    required String title,
    required String stepLabel,
    required double progress,
    required VoidCallback onClose,
  }) {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            stepLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0, 1),
            child: Container(height: 4, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget profile({
    required String title,
    VoidCallback? onSettings,
  }) {
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: AppColors.darkText,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        const Gap(4),
      ],
    );
  }

  static PreferredSizeWidget title({
    required String title,
    VoidCallback? onBack,
  }) {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color(0xFFF8F9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: onBack == null
          ? null
          : IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      title: Text(title),
    );
  }
}
