import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/strings.dart';
import '../../design/sky/sky_palette.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';
import '../../design/widgets/press_scale.dart';
import '../../data/services/cache_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        palette: SkyPalettes.clearNight,
        reduceMotion: settings.reduceMotion ||
            MediaQuery.of(context).disableAnimations,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              NimbusSpacing.xl, NimbusSpacing.base, NimbusSpacing.xl, NimbusSpacing.xxl,
            ),
            children: [
              _Header(onBack: () => context.pop()),
              const SizedBox(height: NimbusSpacing.lg),
              _ChoiceRow(
                label: NimbusStrings.temperatureUnits,
                value: settings.useCelsius ? NimbusStrings.celsius : NimbusStrings.fahrenheit,
                onTap: () => notifier.update(
                  settings.copyWith(useCelsius: !settings.useCelsius),
                ),
              ),
              _ChoiceRow(
                label: NimbusStrings.windUnits,
                value: settings.useKph ? NimbusStrings.kilometresPerHour : NimbusStrings.milesPerHour,
                onTap: () => notifier.update(settings.copyWith(useKph: !settings.useKph)),
              ),
              _ChoiceRow(
                label: NimbusStrings.timeFormat,
                value: settings.use24Hour ? NimbusStrings.time24 : NimbusStrings.time12,
                onTap: () => notifier.update(settings.copyWith(use24Hour: !settings.use24Hour)),
              ),
              _ThemeRow(settings: settings, onChanged: (mode) =>
                  notifier.update(settings.copyWith(themeMode: mode))),
              _SwitchRow(
                label: NimbusStrings.reduceMotion,
                value: settings.reduceMotion,
                onChanged: notifier.setReduceMotion,
              ),
              _SwitchRow(
                label: NimbusStrings.locationOnLaunch,
                value: settings.useLocationOnLaunch,
                onChanged: (value) => notifier.update(
                  settings.copyWith(useLocationOnLaunch: value),
                ),
              ),
              const SizedBox(height: NimbusSpacing.lg),
              const Divider(color: NimbusColors.divider),
              _LinkRow(
                label: NimbusStrings.clearCache,
                onTap: () async {
                  await ref.read(cacheServiceProvider).clearWeatherCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(NimbusStrings.cacheCleared)),
                    );
                  }
                },
              ),
              _LinkRow(label: NimbusStrings.privacyPolicy, onTap: () => context.push('/privacy')),
              _LinkRow(label: NimbusStrings.terms, onTap: () => context.push('/terms')),
              _LinkRow(label: NimbusStrings.about, onTap: () => context.push('/about')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          _IconButton(icon: Icons.arrow_back_rounded, label: NimbusStrings.back, onTap: onBack),
          const SizedBox(width: NimbusSpacing.sm),
          Text(NimbusStrings.settings, style: NimbusTypography.cityName),
        ],
      );
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(width: 48, height: 48, child: Icon(icon, color: NimbusColors.white70)),
        ),
      );
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PressScale(
        semanticLabel: label,
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label, style: NimbusTypography.body),
          trailing: Text(value, style: NimbusTypography.caption),
          minVerticalPadding: NimbusSpacing.sm,
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: NimbusTypography.body),
        value: value,
        onChanged: onChanged,
        activeColor: NimbusColors.accent,
      );
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.settings, required this.onChanged});
  final NimbusSettings settings;
  final ValueChanged<NimbusThemeMode> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<NimbusThemeMode>(
        value: settings.themeMode,
        dropdownColor: const Color(0xFF1A2030),
        decoration: InputDecoration(
          labelText: NimbusStrings.theme,
          labelStyle: NimbusTypography.caption,
          border: InputBorder.none,
        ),
        style: NimbusTypography.body,
        items: const [
          DropdownMenuItem(value: NimbusThemeMode.auto, child: Text(NimbusStrings.themeAuto)),
          DropdownMenuItem(value: NimbusThemeMode.dark, child: Text(NimbusStrings.themeDark)),
          DropdownMenuItem(value: NimbusThemeMode.light, child: Text(NimbusStrings.themeLight)),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PressScale(
        semanticLabel: label,
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label, style: NimbusTypography.body),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: NimbusColors.white50),
        ),
      );
}
