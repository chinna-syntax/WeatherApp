import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/cities/cities_screen.dart';
import '../../features/details/details_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/legal/legal_screen.dart';

const savedCityKey = 'saved_city';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RootRedirect(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadeThrough(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadeThrough(
          state,
          const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => _sharedAxisSlide(
          state,
          const SearchScreen(),
          direction: AxisDirection.up,
        ),
      ),
      GoRoute(
        path: '/cities',
        pageBuilder: (context, state) => _sharedAxisSlide(
          state,
          const CitiesScreen(),
          direction: AxisDirection.right,
        ),
      ),
      GoRoute(
        path: '/details',
        pageBuilder: (context, state) => _sharedAxisSlide(
          state,
          const DetailsScreen(),
          direction: AxisDirection.up,
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _sharedAxisSlide(
          state,
          const SettingsScreen(),
          direction: AxisDirection.left,
        ),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) => _fadeThrough(
          state,
          const LegalScreen(type: LegalType.privacy),
        ),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) => _fadeThrough(
          state,
          const LegalScreen(type: LegalType.terms),
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _fadeThrough(
          state,
          const LegalScreen(type: LegalType.about),
        ),
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Custom page transition builders
// ---------------------------------------------------------------------------

/// Fade-through: fades out current page while new one fades in.
CustomTransitionPage<void> _fadeThrough(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Shared-axis slide: slides in from [direction].
CustomTransitionPage<void> _sharedAxisSlide(
  GoRouterState state,
  Widget child, {
  required AxisDirection direction,
}) {
  Offset beginOffset;
  switch (direction) {
    case AxisDirection.up:
      beginOffset = const Offset(0, 0.06);
      break;
    case AxisDirection.right:
      beginOffset = const Offset(-0.06, 0);
      break;
    case AxisDirection.left:
      beginOffset = const Offset(0.06, 0);
      break;
    case AxisDirection.down:
      beginOffset = const Offset(0, -0.06);
      break;
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Root redirect widget
// ---------------------------------------------------------------------------

class RootRedirect extends StatefulWidget {
  const RootRedirect({super.key});

  @override
  State<RootRedirect> createState() => _RootRedirectState();
}

class _RootRedirectState extends State<RootRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(savedCityKey);
    if (!mounted) return;
    if (saved != null && saved.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
