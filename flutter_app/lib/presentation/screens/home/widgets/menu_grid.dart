import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class MenuGrid extends StatelessWidget {
  final VoidCallback onQuranTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onPrayerTap;
  final VoidCallback onHadithTap;

  const MenuGrid({
    super.key,
    required this.onQuranTap,
    required this.onLibraryTap,
    required this.onPrayerTap,
    required this.onHadithTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MenuCard(
            icon: '📖',
            title: AppStrings.menuQuran,
            onTap: onQuranTap),
        _MenuCard(
            icon: '📚',
            title: AppStrings.menuLibrary,
            onTap: onLibraryTap),
        _MenuCard(
            icon: '🕌',
            title: AppStrings.menuPrayer,
            onTap: onPrayerTap),
        _MenuCard(
            icon: '✨',
            title: AppStrings.menuHadith,
            onTap: onHadithTap),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.gold.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
