import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/app_failure.dart';
import '../../core/strings.dart';
import '../../data/models/weather_models.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/cache_service.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';
import '../../core/settings/settings_controller.dart';
import '../home/home_controller.dart';

// ---------------------------------------------------------------------------
// Search state & controller
// ---------------------------------------------------------------------------

enum _SearchStatus { idle, loading, results, noResults, error }

class _SearchState {
  const _SearchState({
    this.query = '',
    this.results = const [],
    this.status = _SearchStatus.idle,
    this.errorMessage,
  });

  final String query;
  final List<SearchResult> results;
  final _SearchStatus status;
  final String? errorMessage;

  _SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    _SearchStatus? status,
    String? errorMessage,
  }) =>
      _SearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ---------------------------------------------------------------------------
// Search screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  _SearchState _state = const _SearchState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _state = const _SearchState());
      return;
    }
    setState(() => _state = _state.copyWith(
          query: query,
          status: _SearchStatus.loading,
        ));
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final repo = ref.read(weatherRepositoryProvider);
      final results = await repo.searchLocations(query);
      if (!mounted) return;
      setState(() => _state = _state.copyWith(
            results: results,
            status: results.isEmpty
                ? _SearchStatus.noResults
                : _SearchStatus.results,
          ));
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _state = _state.copyWith(
            status: _SearchStatus.error,
            errorMessage: e.message,
          ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _state.copyWith(
            status: _SearchStatus.error,
            errorMessage: NimbusStrings.errorUnknown,
          ));
    }
  }

  Future<void> _selectResult(SearchResult result) async {
    HapticFeedback.selectionClick();
    // Add to saved cities
    final cacheService = ref.read(cacheServiceProvider);
    final city = SavedCity(
      query: result.queryString,
      name: result.name,
      country: result.country,
    );
    await cacheService.addCity(city);
    // Refresh saved cities list
    ref.invalidate(savedCitiesProvider);

    // Switch home to this city
    await ref.read(homeControllerProvider.notifier).switchCity(result.queryString);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(settingsProvider).reduceMotion ||
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultSkyBackground(
        reduceMotion: reduceMotion,
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NimbusSpacing.base,
                  NimbusSpacing.base,
                  NimbusSpacing.base,
                  NimbusSpacing.sm,
                ),
                child: _SearchBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  onBack: () => context.pop(),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0, duration: 300.ms),

              // Results
              Expanded(
                child: _SearchBody(
                  state: _state,
                  onSelectResult: _selectResult,
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
// Sub-widgets
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Go back',
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_rounded,
                color: NimbusColors.white70,
                size: 22,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: NimbusColors.white10,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NimbusColors.white30),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: NimbusTypography.body,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: NimbusStrings.searchHint,
                hintStyle: NimbusTypography.body.copyWith(
                  color: NimbusColors.white30,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NimbusSpacing.base,
                  vertical: 0,
                ),
                suffixIcon: const Icon(
                  Icons.search_rounded,
                  color: NimbusColors.white50,
                  size: 18,
                ),
              ),
              cursorColor: NimbusColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.state,
    required this.onSelectResult,
  });

  final _SearchState state;
  final Future<void> Function(SearchResult) onSelectResult;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case _SearchStatus.idle:
        return _CenteredMessage(
          icon: Icons.search_rounded,
          message: NimbusStrings.searchEmpty,
        );
      case _SearchStatus.loading:
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: NimbusColors.white50,
            ),
          ),
        );
      case _SearchStatus.noResults:
        return _CenteredMessage(
          icon: Icons.location_off_outlined,
          message: NimbusStrings.searchNoResults,
        );
      case _SearchStatus.error:
        return _CenteredMessage(
          icon: Icons.cloud_off_outlined,
          message: state.errorMessage ?? NimbusStrings.errorUnknown,
        );
      case _SearchStatus.results:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: NimbusSpacing.base,
            vertical: NimbusSpacing.sm,
          ),
          itemCount: state.results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: NimbusColors.divider,
          ),
          itemBuilder: (context, i) {
            final result = state.results[i];
            return _ResultTile(
              result: result,
              onTap: () => onSelectResult(result),
            )
                .animate(delay: (i * 30).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.04, end: 0, duration: 300.ms);
          },
        );
    }
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: result.displayName,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            vertical: NimbusSpacing.md,
            horizontal: NimbusSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: NimbusColors.white50,
              ),
              const SizedBox(width: NimbusSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.name,
                        style: NimbusTypography.searchResultPrimary),
                    Text(
                      '${result.region.isNotEmpty ? "${result.region}, " : ""}${result.country}',
                      style: NimbusTypography.searchResultSecondary,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: NimbusColors.white30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: NimbusColors.white30),
          const SizedBox(height: NimbusSpacing.base),
          Text(
            message,
            style: NimbusTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
