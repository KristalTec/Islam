import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/home_provider.dart';

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                  AppStrings.historyTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // History list
                Flexible(
                  child: provider.readingHistory.isEmpty
                      ? const Center(
                          child: Text(
                            AppStrings.historyEmpty,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.readingHistory.length,
                          itemBuilder: (ctx, i) {
                            final item = provider.readingHistory[i];
                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(8),
                                border: const Border(
                                  right: BorderSide(
                                      color: AppColors.gold, width: 3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    '📖 ${item.surahName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 15),

                // Action buttons
                Row(
                  children: [
                    if (provider.readingHistory.isNotEmpty)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  content:
                                      const Text(AppStrings.confirm),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(_, false),
                                      child:
                                          const Text(AppStrings.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(_, true),
                                      child: const Text(AppStrings.ok),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (confirm == true) {
                              provider.clearHistory();
                            }
                          },
                          child:
                              const Text(AppStrings.historyClear),
                        ),
                      ),
                    if (provider.readingHistory.isNotEmpty)
                      const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(AppStrings.close),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
