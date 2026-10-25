import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/weather_models.dart';
import '../../design/sky/sky_palette.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';
import '../../design/widgets/weather_icon.dart';
import '../home/home_controller.dart';
import '../../core/settings/settings_controller.dart';

class CitiesScreen extends ConsumerWidget {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(savedCitiesProvider);
    final currentQuery = ref.watch(homeControllerProvider).savedQuery;
    final useCelsius = ref.watch(settingsProvider).useCelsius;
    final reduceMotion = ref.watch(settingsProvider).reduceMotion ||
        MediaQuery.of(context).disableAnimations;

    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 20;
    final palette = isDay ? SkyPalettes.clearDay : SkyPalettes.clearNight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        palette: palette,
        reduceMotion: reduceMotion,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NimbusSpacing.xl,
                  NimbusSpacing.base,
                  NimbusSpacing.base,
                  NimbusSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        NimbusStrings.citiesTitle,
                        style: NimbusTypography.cityName,
                      ),
                    ),
                    // Search / add button
                    Semantics(
                      button: true,
                      label: NimbusStrings.addCity,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push('/search');
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            color: NimbusColors.white70,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Close',
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close_rounded,
                            color: NimbusColors.white70,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cities list
              Expanded(
                child: cities.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NimbusSpacing.base,
                          vertical: NimbusSpacing.sm,
                        ),
                        itemCount: cities.length,
                        itemBuilder: (context, i) {
                          final city = cities[i];
                          final isCurrent = city.query == currentQuery;
                          return _CityCard(
                            city: city,
                            isCurrent: isCurrent,
                            useCelsius: useCelsius,
                            index: i,
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              await ref
                                  .read(homeControllerProvider.notifier)
                                  .switchCity(city.query);
                              if (context.mounted) context.go('/home');
                            },
                            onDelete: () async {
                              HapticFeedback.selectionClick();
                              final notifier =
                                  ref.read(savedCitiesProvider.notifier);
                              final removed =
                                  await notifier.removeCity(city.query);
                              if (removed != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      NimbusStrings.cityDeleted,
                                      style: NimbusTypography.caption.copyWith(
                                        color: NimbusColors.white,
                                      ),
                                    ),
                                    backgroundColor: NimbusColors.offlineBg,
                                    action: SnackBarAction(
                                      label: NimbusStrings.undo,
                                      textColor: NimbusColors.accent,
                                      onPressed: () {
                                        ref
                                            .read(savedCitiesProvider.notifier)
                                            .restoreCity(removed, i);
                                      },
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                              .animate(delay: (i * 40).ms)
                              .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
                              .slideY(begin: 0.08, end: 0, duration: 350.ms);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CityCard extends ConsumerWidget {
  const _CityCard({
    required this.city,
    required this.isCurrent,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.useCelsius,
  });

  final SavedCity city;
  final bool isCurrent;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool useCelsius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(cityWeatherProvider(city.query));

    return Semantics(
      button: true,
      selected: isCurrent,
      label: '${city.name}${isCurrent ? ", currently selected" : ""}',
      child: Dismissible(
        key: ValueKey(city.query),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: NimbusSpacing.xl),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: NimbusColors.white50,
            size: 22,
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: NimbusSpacing.xs),
            decoration: BoxDecoration(
              color: isCurrent
                  ? NimbusColors.white10
                  : NimbusColors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(20),
              border: isCurrent
                  ? Border.all(color: NimbusColors.white30, width: 0.8)
                  : null,
            ),
            child: weatherAsync.when(
              data: (weather) => _CityCardContent(
                city: city,
                weather: weather,
                isCurrent: isCurrent,
                useCelsius: useCelsius,
              ),
              loading: () => _CityCardSkeleton(name: city.name),
              error: (_, __) => _CityCardError(name: city.name),
            ),
          ),
        ),
      ),
    );
  }
}

class _CityCardContent extends StatelessWidget {
  const _CityCardContent({
    required this.city,
    required this.weather,
    required this.isCurrent,
    required this.useCelsius,
  });

  final SavedCity city;
  final WeatherResponse weather;
  final bool isCurrent;
  final bool useCelsius;

  @override
  Widget build(BuildContext context) {
    final palette = paletteFromCondition(
      weather.current.condition.code,
      weather.current.isDay,
    );
    final temp = Formatters.formatTemp(Formatters.convertTemp(
      weather.current.tempC,
      useCelsius: useCelsius,
    ));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.top.withAlpha(60),
            palette.bottom.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: NimbusSpacing.base,
        vertical: NimbusSpacing.md,
      ),
      child: Row(
        children: [
          // City info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weather.location.name,
                    style: NimbusTypography.cityCardName),
                const SizedBox(height: 2),
                Text(weather.current.condition.text,
                    style: NimbusTypography.caption),
              ],
            ),
          ),
          // Icon
          WeatherIcon(
            conditionCode: weather.current.condition.code,
            isDay: weather.current.isDay,
            size: 28,
            opacity: 0.7,
          ),
          const SizedBox(width: NimbusSpacing.md),
          // Temperature
          Text('$temp°', style: NimbusTypography.cityCardTemp),
        ],
      ),
    );
  }
}

class _CityCardSkeleton extends StatelessWidget {
  const _CityCardSkeleton({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: NimbusSpacing.base, vertical: NimbusSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(name, style: NimbusTypography.cityCardName)),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.2,
              color: NimbusColors.white30,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityCardError extends StatelessWidget {
  const _CityCardError({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: NimbusSpacing.base, vertical: NimbusSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(name, style: NimbusTypography.cityCardName)),
          const Icon(Icons.cloud_off_outlined,
              size: 16, color: NimbusColors.white30),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_location_outlined,
              size: 40, color: NimbusColors.white30),
          const SizedBox(height: NimbusSpacing.base),
          Text(
            NimbusStrings.noCities,
            style: NimbusTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
