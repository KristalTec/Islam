import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/home_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 15),

                const Text(
                  AppStrings.settingsTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Notification toggle
                GestureDetector(
                  onTap: provider.toggleNotifications,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: provider.notifActive
                          ? const Color(0xFFE8F8F5)
                          : const Color(0xFFFDEDEC),
                      border: Border.all(
                        color: provider.notifActive
                            ? AppColors.green
                            : AppColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.notifActive
                          ? AppStrings.notifDisable
                          : AppStrings.notifEnable,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: provider.notifActive
                            ? AppColors.green
                            : AppColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Stats
                _StatRow(
                    label: AppStrings.myVisits,
                    value: '${provider.visitCount}'),
                _StatRow(
                    label: AppStrings.onlineUsers,
                    value: '${provider.onlineCount}',
                    valueColor: AppColors.green),

                const SizedBox(height: 15),

                // Contact
                const Divider(),
                const Text(
                  AppStrings.contact,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialBtn(emoji: '📘', tooltip: 'Facebook'),
                    const SizedBox(width: 10),
                    _SocialBtn(emoji: '📸', tooltip: 'Instagram'),
                    const SizedBox(width: 10),
                    _SocialBtn(emoji: '👻', tooltip: 'Snapchat'),
                    const SizedBox(width: 10),
                    _SocialBtn(emoji: '🎵', tooltip: 'TikTok'),
                  ],
                ),
                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppStrings.close),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String emoji;
  final String tooltip;

  const _SocialBtn({required this.emoji, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
    );
  }
}
