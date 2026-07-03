import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/prayer_provider.dart';
import 'widgets/prayer_card.dart';

/// Map of city API keys to Kurdish display names.
const Map<String, String> _cityNames = {
  'Sulaymaniyah': 'سلێمانی',
  'Erbil': 'هەولێر',
  'Duhok': 'دهۆک',
  'Kirkuk': 'کەرکوک',
  'Halabja': 'هەڵەبجە',
  'Baghdad': 'بەغداد',
  'Zakho': 'زاخۆ',
  'Soran': 'سۆران',
  'Kalar': 'کەلار',
  'Ranya': 'ڕانیە',
  'Chamchamal': 'چەمچەماڵ',
  'Koya': 'کۆیە',
  'Akre': 'ئاکرێ',
  'Darbandikhan': 'دەربەندیخان',
  'Penjwen': 'پێنجوێن',
  'Qaladze': 'قەڵادزێ',
  'Khanaqin': 'خانەقین',
  'Dukan': 'دوکان',
  'Rawanduz': 'ڕەواندز',
  'Shaqlawa': 'شەقڵاوە',
  'Amadiya': 'ئامێدی',
};

const Map<String, String> _soundNames = {
  'makkah': AppStrings.adhanMakkah,
  'madina': AppStrings.adhanMadina,
  'aqsa': AppStrings.adhanAqsa,
  'mishary': AppStrings.adhanMishary,
  'abdulbasit': AppStrings.adhanAbdulbasit,
};

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Consumer<PrayerProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                _PrayerHeader(provider: provider),
                if (provider.showAdhanAlert) _AdhanAlert(provider: provider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Date row
                        if (provider.prayerTimes != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                provider.prayerTimes!.gregorianDate,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${provider.prayerTimes!.hijriDay} ${provider.prayerTimes!.hijriMonthEn}',
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.gold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],

                        // Prayer cards
                        if (provider.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.gold),
                          )
                        else if (provider.hasError)
                          Center(
                            child: Column(
                              children: [
                                const Text(AppStrings.connectionError,
                                    style: TextStyle(color: Colors.red)),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: provider.fetchPrayerTimes,
                                  child:
                                      const Text(AppStrings.retry),
                                ),
                              ],
                            ),
                          )
                        else if (provider.prayerTimes != null)
                          _PrayerGrid(provider: provider)
                        else
                          const SizedBox.shrink(),

                        const SizedBox(height: 20),
                        const Text(
                          AppStrings.prayerNote,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
}

class _PrayerHeader extends StatelessWidget {
  final PrayerProvider provider;

  const _PrayerHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 15,
        right: 15,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gold,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button (only if pushed)
              if (Navigator.canPop(context))
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '↪',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: const Text(
                    AppStrings.prayerTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 15),

          // Settings box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // City selector
                _CityDropdown(provider: provider),
                const SizedBox(height: 8),
                // Audio controls
                _AudioControls(provider: provider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final PrayerProvider provider;

  const _CityDropdown({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.currentCity,
          isExpanded: true,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
            color: AppColors.textDark,
          ),
          items: _cityNames.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
          onChanged: (city) {
            if (city != null) provider.changeCity(city);
          },
        ),
      ),
    );
  }
}

class _AudioControls extends StatelessWidget {
  final PrayerProvider provider;

  const _AudioControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Adhan sound selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.currentSound,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: AppColors.textDark,
                ),
                items: _soundNames.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (key) {
                  if (key != null) provider.changeSound(key);
                },
              ),
            ),
          ),

          // 12/24h toggle
          GestureDetector(
            onTap: provider.toggleTimeFormat,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.use12h ? '12H' : '24H',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Volume slider
          SizedBox(
            width: 80,
            child: Slider(
              value: provider.volume,
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: AppColors.gold,
              inactiveColor: Colors.grey.shade300,
              onChanged: provider.setVolume,
            ),
          ),

          // Mute button
          IconButton(
            icon: Text(
              provider.isMuted ? '🔕' : '🔔',
              style: const TextStyle(fontSize: 20),
            ),
            onPressed: provider.toggleMute,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _AdhanAlert extends StatelessWidget {
  final PrayerProvider provider;

  const _AdhanAlert({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: provider.dismissAdhanAlert,
      child: _PulsingWidget(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '🕌 الله أكبر! ${AppStrings.adhanAlert}${provider.adhanAlertPrayer ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PulsingWidget extends StatefulWidget {
  final Widget child;
  const _PulsingWidget({required this.child});

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.02).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

class _PrayerGrid extends StatelessWidget {
  final PrayerProvider provider;

  const _PrayerGrid({required this.provider});

  static const List<Map<String, String>> _prayers = [
    {'key': 'Fajr', 'name': AppStrings.fajr},
    {'key': 'Sunrise', 'name': AppStrings.sunrise},
    {'key': 'Dhuhr', 'name': AppStrings.dhuhr},
    {'key': 'Asr', 'name': AppStrings.asr},
    {'key': 'Maghrib', 'name': AppStrings.maghrib},
    {'key': 'Isha', 'name': AppStrings.isha},
  ];

  @override
  Widget build(BuildContext context) {
    final timings = provider.prayerTimes!.timingsMap;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: _prayers.map((p) {
        final isActive = provider.activePrayer == p['key'];
        final timeStr = timings[p['key']] ?? '';
        return PrayerCardWidget(
          name: p['name']!,
          time: provider.formatTime(timeStr),
          isActive: isActive,
        );
      }).toList(),
    );
  }
}
