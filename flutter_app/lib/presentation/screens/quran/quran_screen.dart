import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/quran_provider.dart';
import '../../../data/models/quran_model.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgCream,
        body: Consumer<QuranProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                _QuranHeader(provider: provider),
                Expanded(child: _QuranContent(provider: provider)),
                _QuranFooter(provider: provider),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuranHeader extends StatelessWidget {
  final QuranProvider provider;

  const _QuranHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 15,
        right: 15,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Back/Home button
          if (Navigator.canPop(context))
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🏠 🔙',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          const SizedBox(width: 10),

          // Surah selector
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: provider.currentSurahNumber,
                  isExpanded: true,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                  items: provider.surahList.isNotEmpty
                      ? provider.surahList
                          .map((s) => DropdownMenuItem(
                                value: s.number,
                                child: Text(s.displayName),
                              ))
                          .toList()
                      : [
                          DropdownMenuItem(
                            value: 1,
                            child: const Text('1. سورة الفاتحة'),
                          )
                        ],
                  onChanged: (n) {
                    if (n != null) provider.loadSurah(n);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranContent extends StatelessWidget {
  final QuranProvider provider;

  const _QuranContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 16),
            Text(AppStrings.quranLoading,
                style: TextStyle(color: AppColors.gold)),
          ],
        ),
      );
    }

    if (provider.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            AppStrings.quranOffline,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        textDirection: TextDirection.rtl,
        children: [
          // Basmala (except Al-Fatiha already has it, and Al-Tawbah)
          if (provider.currentSurahNumber != 1 &&
              provider.currentSurahNumber != 9)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  AppStrings.basmala,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                  ),
                ),
              ),
            ),

          // Ayahs
          ...provider.currentAyahs.asMap().entries.map((entry) {
            final ayahIdx = entry.key;
            final ayah = entry.value;
            String text = ayah.text;
            // Remove basmala from first ayah of non-Fatiha, non-Tawbah
            if (provider.currentSurahNumber != 1 &&
                provider.currentSurahNumber != 9 &&
                ayahIdx == 0) {
              text = text
                  .replaceFirst(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
                  .trim();
            }
            return _AyahWidget(
              ayahIndex: ayahIdx,
              text: text,
              numberInSurah: ayah.numberInSurah,
              highlightedWords: provider.highlightedWords,
              isCurrentAyah: ayahIdx == provider.currentAyahIndex,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _AyahWidget extends StatelessWidget {
  final int ayahIndex;
  final String text;
  final int numberInSurah;
  final Map<String, bool> highlightedWords;
  final bool isCurrentAyah;

  const _AyahWidget({
    required this.ayahIndex,
    required this.text,
    required this.numberInSurah,
    required this.highlightedWords,
    required this.isCurrentAyah,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      textDirection: TextDirection.rtl,
      children: [
        ...words.asMap().entries.map((entry) {
          final wordIdx = entry.key;
          final word = entry.value;
          final key = '$ayahIndex-$wordIdx';
          final isHighlighted = highlightedWords[key] == true;
          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 100),
            style: TextStyle(
              fontSize: 32,
              height: 2.6,
              fontFamily: 'Amiri',
              color: isHighlighted ? AppColors.green : const Color(0xFF2C3E50),
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              backgroundColor: isHighlighted
                  ? AppColors.green.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Text('$word '),
          );
        }).toList(),

        // Ayah number badge
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold),
          ),
          child: Text(
            '$numberInSurah',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.gold,
            ),
          ),
        ),
        const Text(' ', style: TextStyle(fontSize: 32)),
      ],
    );
  }
}

class _QuranFooter extends StatelessWidget {
  final QuranProvider provider;

  const _QuranFooter({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
              color: Colors.black05,
              blurRadius: 15,
              offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live caption
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              provider.liveCaption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF555555),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Favorites button
              GestureDetector(
                onTap: () async {
                  final saved = await provider.saveToFavorites();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved
                            ? AppStrings.quranSaved
                            : AppStrings.quranAlreadySaved,
                      ),
                      backgroundColor:
                          saved ? AppColors.green : Colors.orange,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Center(
                    child: Text('❤️', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Microphone button
              GestureDetector(
                onTap: provider.speechAvailable
                    ? provider.toggleListening
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Speech recognition not available'),
                          ),
                        ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  decoration: BoxDecoration(
                    color: provider.isListening
                        ? const Color(0xFFE74C3C)
                        : AppColors.gold,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isListening
                                ? const Color(0xFFE74C3C)
                                : AppColors.gold)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.isListening ? '⏹' : '🎤',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isListening
                            ? AppStrings.quranStop
                            : AppStrings.quranStart,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.madeBy,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
