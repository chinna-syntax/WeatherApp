import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../core/utils/formatters.dart';
import '../../design/sky/sky_palette.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/section_heading.dart';
import '../../design/widgets/shimmer.dart';
import '../../design/widgets/sky_background.dart';
import '../../design/widgets/press_scale.dart';
import 'home_controller.dart';
import 'widgets/daily_forecast.dart';
import 'widgets/error_view.dart';
import 'widgets/hourly_strip.dart';
import 'widgets/stats_row.dart';
import 'widgets/temperature_display.dart';
import '../../core/settings/settings_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).loadSavedCity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final settings = ref.watch(settingsProvider);
    final isOffline = ref.watch(isOfflineProvider);

    final palette = state.weather != null
        ? paletteFromCondition(
            state.weather!.current.condition.code,
            state.weather!.current.isDay,
          )
        : SkyPalettes.clearDay;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        palette: palette,
        reduceMotion: settings.reduceMotion ||
            MediaQuery.of(context).disableAnimations,
        effect: weatherEffectForCondition(
          state.weather?.current.condition.code,
          isDay: state.weather?.current.isDay ?? true,
        ),
        child: Stack(
          children: [
            if (state.isLoading && !state.hasData)
              const HomeScreenSkeleton()
            else if (state.hasError)
              HomeErrorView(
                failure: state.failure!,
                onRetry: () =>
                    ref.read(homeControllerProvider.notifier).refresh(),
              )
            else if (state.hasData)
              _HomeContent(
                state: state.copyWith(useCelsius: settings.useCelsius),
              )
            else
              const HomeScreenSkeleton(),

            // Offline / stale data banner
            if (isOffline || (state.isFromCache && state.cacheAgeLabel != null))
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CacheBanner(
                  isOffline: isOffline,
                  ageLabel: state.cacheAgeLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final weather = state.weather!;
    final current = weather.current;
    final location = weather.location;
    final days = weather.forecast.forecastDays;
    final today = days.isNotEmpty ? days.first : null;

    final localtime = location.localtimeEpoch > 0
        ? DateTime.fromMillisecondsSinceEpoch(location.localtimeEpoch * 1000)
        : DateTime.now();

    // Collect all hourly data across forecast days
    final allHours = days.expand((d) => d.hour).toList();

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.selectionClick();
        await ref.read(homeControllerProvider.notifier).refresh();
      },
      color: NimbusColors.white,
      backgroundColor: Colors.transparent,
      strokeWidth: 1.5,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Top bar: cities + search buttons
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NimbusSpacing.xl,
                  vertical: NimbusSpacing.base,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.menu_rounded,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.push('/cities');
                      },
                      label: 'Cities',
                    ),
                    _NavButton(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.push('/settings');
                      },
                      label: NimbusStrings.settings,
                    ),
                    _NavButton(
                      icon: Icons.search_rounded,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.push('/search');
                      },
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: NimbusSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: NimbusSpacing.md),

                  // City name
                  Semantics(
                    header: true,
                    child: _CityHeader(cityName: location.name),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: NimbusSpacing.sm),

                  // Condition text
                  Text(current.condition.text, style: NimbusTypography.condition)
                      .animate(delay: 40.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: NimbusSpacing.xl),

                  // Giant temperature
                  Semantics(
                    label: NimbusStrings.tempSemantic(
                      Formatters.formatTemp(Formatters.convertTemp(
                          current.tempC, useCelsius: state.useCelsius)),
                      Formatters.unitSymbol(useCelsius: state.useCelsius),
                      '${Formatters.formatTemp(Formatters.convertTemp(current.feelsLikeC, useCelsius: state.useCelsius))}${Formatters.unitSymbol(useCelsius: state.useCelsius)}',
                    ),
                    excludeSemantics: true,
                    child: TemperatureDisplay(
                      tempC: current.tempC,
                      useCelsius: state.useCelsius,
                    ),
                  )
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: NimbusSpacing.base),

                  // Feels like + H/L
                  _FeelsLikeLine(
                    feelsLikeC: current.feelsLikeC,
                    maxC: today?.day.maxTempC,
                    minC: today?.day.minTempC,
                    useCelsius: state.useCelsius,
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                          begin: 0.1, end: 0, duration: 500.ms,
                          curve: Curves.easeOutCubic),

                  const SizedBox(height: NimbusSpacing.sm),

                  // Timestamp
                  Text(
                    '${NimbusStrings.updatedAt} ${Formatters.formatTime(localtime, use24Hour: settings.use24Hour)}',
                    style: NimbusTypography.timestamp,
                  )
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: NimbusSpacing.xl),

                  // Stats row
                  Semantics(
                    container: true,
                    child: StatsRow(
                      humidity: current.humidity,
                      windKph: current.windKph,
                      windDir: current.windDir,
                      uv: current.uv,
                      useKph: settings.useKph,
                    ),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                          begin: 0.1, end: 0, duration: 500.ms,
                          curve: Curves.easeOutCubic),

                  const SizedBox(height: NimbusSpacing.xl),
                ],
              ),
            ),
          ),

          // Hourly strip (full-width, no horizontal padding)
          if (allHours.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: NimbusSpacing.xl),
                    child: const SectionHeading(label: 'Hourly'),
                  ),
                  HourlyForecastStrip(
                    hours: allHours,
                    useCelsius: state.useCelsius,
                  )
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),
                ],
              ),
            ),

          // Daily forecast
          if (days.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: NimbusSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: NimbusSpacing.xl),
                    const SectionHeading(label: 'Forecast'),
                    DailyForecast(
                      days: days,
                      useCelsius: state.useCelsius,
                    )
                        .animate(delay: 280.ms)
                        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),

          // Details button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: NimbusSpacing.xl,
                  vertical: NimbusSpacing.xl),
              child: _DetailsButton(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/details');
                },
              )
                  .animate(delay: 320.ms)
                  .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: NimbusSpacing.xxl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: NimbusColors.white70, size: 22),
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  const _CityHeader({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            cityName,
            style: NimbusTypography.cityName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: NimbusSpacing.sm),
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: NimbusColors.white70,
        ),
      ],
    );
  }
}

class _FeelsLikeLine extends StatelessWidget {
  const _FeelsLikeLine({
    required this.feelsLikeC,
    this.maxC,
    this.minC,
    required this.useCelsius,
  });

  final double feelsLikeC;
  final double? maxC;
  final double? minC;
  final bool useCelsius;

  @override
  Widget build(BuildContext context) {
    final fl = Formatters.formatTemp(
        Formatters.convertTemp(feelsLikeC, useCelsius: useCelsius));
    final unit = Formatters.unitSymbol(useCelsius: useCelsius);
    final parts = <String>['${NimbusStrings.feelsLike} $fl$unit'];
    if (maxC != null && minC != null) {
      final hi = Formatters.formatTemp(
          Formatters.convertTemp(maxC!, useCelsius: useCelsius));
      final lo = Formatters.formatTemp(
          Formatters.convertTemp(minC!, useCelsius: useCelsius));
      parts.add(
          '${NimbusStrings.high}:$hi$unit  ${NimbusStrings.low}:$lo$unit');
    }
    return Text(parts.join('   ·   '), style: NimbusTypography.feelsLike);
  }
}

class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      semanticLabel: 'View detailed weather information',
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: NimbusSpacing.md, horizontal: NimbusSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: NimbusColors.white30),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'More details',
                style: NimbusTypography.buttonLabel.copyWith(
                  color: NimbusColors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: NimbusSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: NimbusColors.white50,
              ),
            ],
          ),
        ),
    );
  }
}

class _CacheBanner extends StatelessWidget {
  const _CacheBanner({required this.isOffline, this.ageLabel});

  final bool isOffline;
  final String? ageLabel;

  @override
  Widget build(BuildContext context) {
    final message = isOffline
        ? NimbusStrings.errorOffline
        : '${NimbusStrings.errorOfflineWithAge} $ageLabel';

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: NimbusColors.offlineBg,
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: NimbusSpacing.base),
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.history_rounded,
              size: 13,
              color: NimbusColors.white70,
            ),
            const SizedBox(width: NimbusSpacing.sm),
            Text(
              message,
              style: NimbusTypography.timestamp.copyWith(
                color: NimbusColors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
