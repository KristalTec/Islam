import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/hadith_provider.dart';
import '../../../data/models/hadith_model.dart';
import 'widgets/hadith_card_widget.dart';

const List<Map<String, String>> _tabs = [
  {'key': 'all', 'label': AppStrings.hadithAll},
  {'key': 'bukhari', 'label': AppStrings.hadithBukhari},
  {'key': 'muslim', 'label': AppStrings.hadithMuslim},
  {'key': 'riyad', 'label': AppStrings.hadithRiyad},
  {'key': 'qudsi', 'label': AppStrings.hadithQudsi},
];

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgCream,
        body: Column(
          children: [
            _HadithHeader(scrollController: _scrollController),
            Expanded(
              child: Consumer<HadithProvider>(
                builder: (context, provider, _) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Sticky search + tabs
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeader(
                          searchCtrl: _searchCtrl,
                          activeTab: provider.activeTab,
                          onSearch: (q) => provider.search(q),
                          onTabSwitch: (t) {
                            _searchCtrl.clear();
                            provider.switchTab(t);
                          },
                        ),
                      ),
                      // Hadith list
                      if (provider.displayed.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              AppStrings.hadithNotFound,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: HadithCardWidget(
                                  hadith: provider.displayed[i],
                                  onCopy: () =>
                                      _copyHadith(provider.displayed[i]),
                                  onShare: () =>
                                      _shareHadith(provider.displayed[i]),
                                ),
                              ),
                              childCount: provider.displayed.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyHadith(HadithModel h) {
    Clipboard.setData(ClipboardData(
        text: '${h.arabic}\n\n${h.kurdish}\n\nلە ئەپی Islam Online'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.hadithCopied),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _shareHadith(HadithModel h) {
    Share.share('${h.arabic}\n\n${h.kurdish}\n\n');
  }
}

class _HadithHeader extends StatelessWidget {
  final ScrollController scrollController;

  const _HadithHeader({required this.scrollController});

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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (Navigator.canPop(context))
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('⬅️', style: TextStyle(fontSize: 22)),
            )
          else
            const SizedBox(width: 32),
          const Text(
            AppStrings.hadithTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          GestureDetector(
            onTap: () => scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ),
            child: const Text(AppStrings.scrollTop,
                style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final TextEditingController searchCtrl;
  final String activeTab;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onTabSwitch;

  const _StickyHeader({
    required this.searchCtrl,
    required this.activeTab,
    required this.onSearch,
    required this.onTabSwitch,
  });

  @override
  double get minExtent => 110;
  @override
  double get maxExtent => 110;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bgCream,
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      child: Column(
        children: [
          // Search
          TextField(
            controller: searchCtrl,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: AppStrings.hadithSearch,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide:
                    const BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tabs
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final tab = _tabs[i];
                final isActive = activeTab == tab['key'];
                return GestureDetector(
                  onTap: () => onTabSwitch(tab['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.gold : Colors.white,
                      border: Border.all(
                        color:
                            isActive ? AppColors.gold : const Color(0xFFEEEEEE),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.3),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      tab['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isActive ? Colors.white : const Color(0xFF666666),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeader old) =>
      old.activeTab != activeTab;
}
