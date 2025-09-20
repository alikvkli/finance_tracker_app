import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/onboarding_page_model.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageModel pageModel;
  final bool isLastPage;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onGetStarted;

  const OnboardingPageWidget({
    super.key,
    required this.pageModel,
    this.isLastPage = false,
    this.onNext,
    this.onSkip,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation/Image Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildContent(context),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Text Section
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  _getLocalizedText(localizations, pageModel.title),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  _getLocalizedText(localizations, pageModel.description),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip Button
              if (!isLastPage)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    localizations.skip,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Next/Get Started Button
              ElevatedButton(
                onPressed: isLastPage ? onGetStarted : onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  isLastPage ? localizations.getStarted : localizations.next,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Try to load Lottie animation first, fallback to image
    try {
      return Lottie.asset(
        pageModel.animationPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageFallback(context);
        },
      );
    } catch (e) {
      return _buildImageFallback(context);
    }
  }

  Widget _buildImageFallback(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getIconForPage(pageModel.title),
          size: 120,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  IconData _getIconForPage(String title) {
    switch (title) {
      case 'onboarding_welcome':
        return Icons.waving_hand;
      case 'onboarding_track':
        return Icons.track_changes;
      case 'onboarding_analyze':
        return Icons.analytics;
      default:
        return Icons.info;
    }
  }

  String _getLocalizedText(AppLocalizations localizations, String key) {
    switch (key) {
      case 'onboarding_welcome':
        return localizations.onboardingWelcome;
      case 'onboarding_welcome_description':
        return localizations.onboardingWelcomeDescription;
      case 'onboarding_track':
        return localizations.onboardingTrack;
      case 'onboarding_track_description':
        return localizations.onboardingTrackDescription;
      case 'onboarding_analyze':
        return localizations.onboardingAnalyze;
      case 'onboarding_analyze_description':
        return localizations.onboardingAnalyzeDescription;
      default:
        return key;
    }
  }
}
