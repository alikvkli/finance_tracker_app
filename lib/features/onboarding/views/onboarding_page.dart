import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/page_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    final currentPage = ref.read(onboardingControllerProvider).currentPage;
    if (currentPage < AppConstants.onboardingPageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _skipToLast() {
    _pageController.animateToPage(
      AppConstants.onboardingPageCount - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.auth,
        (route) => false,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final pages = ref.read(onboardingControllerProvider.notifier).getOnboardingPages();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PageIndicator(
                currentPage: onboardingState.currentPage,
                totalPages: AppConstants.onboardingPageCount,
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingControllerProvider.notifier).setCurrentPage(index);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final isLastPage = index == pages.length - 1;
                  
                  return OnboardingPageWidget(
                    pageModel: page,
                    isLastPage: isLastPage,
                    onNext: _nextPage,
                    onSkip: _skipToLast,
                    onGetStarted: _completeOnboarding,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
