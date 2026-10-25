import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/app_failure.dart';
import '../../core/strings.dart';
import '../../data/services/location_service.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';
import '../../design/sky/sky_palette.dart';
import '../home/home_controller.dart';
import '../../core/settings/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useLocation() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final query = await locationService.getCurrentLocationQuery();
      if (!mounted) return;
      await ref.read(homeControllerProvider.notifier).loadWeather(query);
      if (!mounted) return;
      context.go('/home');
    } on LocationPermissionFailure catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } on LocationServiceDisabledFailure catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${e.message}\nPlease enable location services.';
      });
    } on AppFailure catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Try searching a city.';
      });
    }
  }

  Future<void> _searchCity(String query) async {
    if (query.trim().isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(homeControllerProvider.notifier).loadWeather(query.trim());
      if (!mounted) return;
      context.go('/home');
    } on AppFailure catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'City not found. Try a different name.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 20;
    final palette = isDay ? SkyPalettes.clearDay : SkyPalettes.clearNight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SkyBackground(
        palette: palette,
        reduceMotion:
            settings.reduceMotion || MediaQuery.of(context).disableAnimations,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: NimbusSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: NimbusSpacing.xxxl),
                  const _Header(),
                  const SizedBox(height: NimbusSpacing.xxxl),
                  _Actions(
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    showSearch: _showSearch,
                    searchController: _searchController,
                    onUseLocation: _useLocation,
                    onShowSearch: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _showSearch = !_showSearch;
                        _errorMessage = null;
                      });
                    },
                    onSearch: _searchCity,
                  ),
                  const SizedBox(height: NimbusSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          NimbusStrings.appName,
          style: NimbusTypography.onboardingTitle,
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.2, end: 0, duration: 600.ms),

        const SizedBox(height: NimbusSpacing.base),

        Text(
          NimbusStrings.onboardingTagline,
          style: NimbusTypography.onboardingSubtitle,
        )
            .animate(delay: 100.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.2, end: 0, duration: 600.ms),

        const SizedBox(height: NimbusSpacing.xl),

        Text(
          NimbusStrings.onboardingLocationRationale,
          style: NimbusTypography.caption,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.1, end: 0, duration: 600.ms),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isLoading,
    required this.errorMessage,
    required this.showSearch,
    required this.searchController,
    required this.onUseLocation,
    required this.onShowSearch,
    required this.onSearch,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool showSearch;
  final TextEditingController searchController;
  final VoidCallback onUseLocation;
  final VoidCallback onShowSearch;
  final Future<void> Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error message
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: NimbusSpacing.base),
            child: Text(
              errorMessage!,
              style: NimbusTypography.caption.copyWith(
                color: NimbusColors.error.withAlpha(230),
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0, duration: 300.ms),

        // Search field (shown when user taps "Search a city")
        if (showSearch)
          Padding(
            padding: const EdgeInsets.only(bottom: NimbusSpacing.base),
            child: _SearchField(
              controller: searchController,
              onSearch: onSearch,
              isLoading: isLoading,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),

        // Primary CTA: Use my location
        if (!showSearch)
          _PrimaryButton(
            label: NimbusStrings.useMyLocation,
            isLoading: isLoading,
            onTap: onUseLocation,
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.15, end: 0, duration: 500.ms),

        const SizedBox(height: NimbusSpacing.base),

        // Secondary: Search a city
        GestureDetector(
          onTap: isLoading ? null : onShowSearch,
          child: Text(
            showSearch
                ? NimbusStrings.useLocationInstead
                : NimbusStrings.searchCityInstead,
            style: NimbusTypography.caption.copyWith(
              color: NimbusColors.white70,
              decoration: TextDecoration.underline,
              decorationColor: NimbusColors.white30,
            ),
            textAlign: TextAlign.center,
          ),
        )
            .animate(delay: 380.ms)
            .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isLoading
              ? NimbusColors.white.withAlpha(38)
              : NimbusColors.white.withAlpha(46),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: NimbusColors.white.withAlpha(isLoading ? 51 : 102),
            width: 1,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: NimbusColors.white,
                  ),
                )
              : Text(label, style: NimbusTypography.buttonLabel),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSearch,
    required this.isLoading,
  });

  final TextEditingController controller;
  final Future<void> Function(String) onSearch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NimbusColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NimbusColors.white30),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: NimbusTypography.body,
        textInputAction: TextInputAction.search,
        onSubmitted: (val) => onSearch(val),
        decoration: InputDecoration(
          hintText: NimbusStrings.searchHint,
          hintStyle: NimbusTypography.body.copyWith(
            color: NimbusColors.white50,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NimbusSpacing.base,
            vertical: NimbusSpacing.base,
          ),
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: NimbusColors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: NimbusColors.white70,
                    size: 20,
                  ),
                  onPressed: () => onSearch(controller.text),
                ),
        ),
        cursorColor: NimbusColors.white,
      ),
    );
  }
}
