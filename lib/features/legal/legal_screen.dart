import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/strings.dart';
import '../../design/sky/sky_palette.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';
import '../../design/widgets/sky_background.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.type});
  final LegalType type;

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalType.privacy;
    final isAbout = type == LegalType.about;
    final title = isAbout
        ? NimbusStrings.about
        : isPrivacy
            ? NimbusStrings.privacyPolicy
            : NimbusStrings.terms;
    final paragraphs = isAbout
        ? NimbusStrings.aboutParagraphs
        : isPrivacy
            ? NimbusStrings.privacyParagraphs
            : NimbusStrings.termsParagraphs;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        palette: SkyPalettes.clearNight,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              NimbusSpacing.xl, NimbusSpacing.base, NimbusSpacing.xl, NimbusSpacing.xxl,
            ),
            children: [
              Row(children: [
                Semantics(
                  button: true,
                  label: NimbusStrings.back,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: NimbusColors.white70),
                  ),
                ),
                Text(title, style: NimbusTypography.cityName),
              ]),
              const SizedBox(height: NimbusSpacing.lg),
              for (final paragraph in paragraphs) ...[
                Text(paragraph, style: NimbusTypography.body),
                const SizedBox(height: NimbusSpacing.base),
              ],
              if (isAbout)
                Semantics(
                  link: true,
                  label: NimbusStrings.poweredBy,
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: NimbusStrings.weatherApiUrl),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(NimbusStrings.linkCopied),
                          ),
                        );
                      }
                    },
                    child: Text(
                      NimbusStrings.poweredBy,
                      style: NimbusTypography.body.copyWith(
                        decoration: TextDecoration.underline,
                        color: NimbusColors.white70,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum LegalType { privacy, terms, about }
