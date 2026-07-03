import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/library_provider.dart';
import '../../../data/models/book_model.dart';
import 'widgets/book_card_widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showHistory = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        body: Consumer<LibraryProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _LibraryHeader(
                    provider: provider,
                    searchCtrl: _searchCtrl,
                    showHistory: _showHistory,
                    onToggleHistory: () =>
                        setState(() => _showHistory = !_showHistory),
                    onSearch: () => provider.initiateSearch(
                        query: _searchCtrl.text),
                  ),
                ),

                // History panel
                if (_showHistory)
                  SliverToBoxAdapter(
                    child: _HistoryPanel(
                      provider: provider,
                      onSelect: (q) {
                        _searchCtrl.text = q;
                        setState(() => _showHistory = false);
                        provider.searchFromHistory(q);
                      },
                    ),
                  ),

                // Results info
                if (provider.resultsInfo.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(
                        provider.resultsInfo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),

                // Loading indicator
                if (provider.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                              color: Color(0xFF2E7D32)),
                          SizedBox(height: 10),
                          Text(AppStrings.libraryLoading),
                        ],
                      ),
                    ),
                  ),

                // Books grid
                SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => BookCardWidget(
                        book: provider.books[i],
                        onRead: () =>
                            _openBook(provider.books[i]),
                      ),
                      childCount: provider.books.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openBook(BookModel book) async {
    if (book.readUrl == null) return;
    final uri = Uri.parse(book.readUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _LibraryHeader extends StatelessWidget {
  final LibraryProvider provider;
  final TextEditingController searchCtrl;
  final bool showHistory;
  final VoidCallback onToggleHistory;
  final VoidCallback onSearch;

  const _LibraryHeader({
    required this.provider,
    required this.searchCtrl,
    required this.showHistory,
    required this.onToggleHistory,
    required this.onSearch,
  });

  static const Map<LibrarySource, String> _sourceLabels = {
    LibrarySource.all: AppStrings.libraryAllSources,
    LibrarySource.openlibrary: AppStrings.libraryOpenLibrary,
    LibrarySource.google: AppStrings.libraryGoogle,
    LibrarySource.archive: AppStrings.libraryArchive,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top buttons
          Row(
            children: [
              _TopBtn(
                label: '🏠 سەرەکی',
                color: const Color(0xFF00796B),
                onTap: Navigator.canPop(context)
                    ? () => Navigator.pop(context)
                    : null,
              ),
              const SizedBox(width: 10),
              _TopBtn(
                label: AppStrings.libraryHistory,
                color: const Color(0xFFF39C12),
                onTap: onToggleHistory,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            AppStrings.libraryTitle,
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.librarySubtitle,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    hintText: AppStrings.librarySearch,
                    filled: true,
                    fillColor: const Color(0xFFF4F7F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFFDDDDDD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFF2E7D32), width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onSearch,
                child: const Text(
                  AppStrings.librarySearchBtn,
                  style: TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Kurdish filter toggle
          GestureDetector(
            onTap: provider.toggleKurdishOnly,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: provider.isKurdishOnly
                    ? const Color(0xFFE8F5E9)
                    : Colors.white,
                border: Border.all(
                  color: provider.isKurdishOnly
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFDDDDDD),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.libraryKurdishOnly,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: provider.isKurdishOnly
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Source tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: LibrarySource.values.map((src) {
              final isActive = provider.source == src;
              return GestureDetector(
                onTap: () => provider.setSource(src),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : Colors.white,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFDDDDDD),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _sourceLabels[src]!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _TopBtn({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  final LibraryProvider provider;
  final ValueChanged<String> onSelect;

  const _HistoryPanel({required this.provider, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            AppStrings.libraryHistoryTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (provider.searchHistory.isEmpty)
            const Text('مێژوو بوونی نییە',
                style: TextStyle(color: Colors.grey)),
          ...provider.searchHistory.map((h) {
            return GestureDetector(
              onTap: () => onSelect(h['query']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h['time']?.split('T').last.substring(0, 5) ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      h['query'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: provider.clearHistory,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFC0392B),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                AppStrings.libraryClearHistory,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
