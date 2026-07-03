import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/home_provider.dart';
import '../quran/quran_screen.dart';
import '../hadith/hadith_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../library/library_screen.dart';
import 'widgets/hero_card.dart';
import 'widgets/menu_grid.dart';
import 'widgets/feed_card.dart';
import '../../widgets/settings_sheet.dart';
import '../../widgets/history_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _HomeHeader(),
          Expanded(
            child: Container(
              color: AppColors.bgCream,
              child: _HomeBody(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 15,
        right: 15,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icons
          Row(
            children: [
              _HeaderBtn(
                icon: '⚙️',
                tooltip: 'ڕێکخستن',
                onTap: () => _openSettings(context),
              ),
              const SizedBox(width: 10),
              _HeaderBtn(
                icon: '🕒',
                tooltip: 'مێژوو',
                onTap: () => _openHistory(context),
              ),
            ],
          ),
          // Title (center)
          Expanded(
            child: Center(
              child: Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          // Refresh
          _HeaderBtn(
            icon: '🔃',
            tooltip: 'نوێکردنەوە',
            onTap: () =>
                context.read<HomeProvider>().triggerUpdate(),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SettingsSheet(),
    );
  }

  void _openHistory(BuildContext context) {
    context.read<HomeProvider>().loadHistory();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const HistorySheet(),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final String icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero card
                  HeroCard(date: provider.currentDate),
                  const SizedBox(height: 25),

                  // Menu grid
                  MenuGrid(
                    onQuranTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QuranScreen())),
                    onLibraryTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LibraryScreen())),
                    onPrayerTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrayerTimesScreen())),
                    onHadithTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HadithScreen())),
                  ),
                  const SizedBox(height: 25),

                  // Feed header
                  _FeedHeader(),
                  const SizedBox(height: 12),
                ]),
              ),
            ),

            // Feed items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: provider.isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          if (i == provider.feedItems.length) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  AppStrings.madeBy,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: FeedCardWidget(
                                item: provider.feedItems[i]),
                          );
                        },
                        childCount: provider.feedItems.length + 1,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FeedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _BlinkingDot(),
            const SizedBox(width: 8),
            const Text(
              AppStrings.feedTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const Text(
          AppStrings.feedLive,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 0.4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
