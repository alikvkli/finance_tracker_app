import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../shared/services/storage_service.dart';
import '../models/onboarding_page_model.dart';

@injectable
class OnboardingController extends StateNotifier<OnboardingState> {
  final StorageService _storageService;
  
  OnboardingController(this._storageService) : super(const OnboardingState());
  
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }
  
  Future<void> completeOnboarding() async {
    await _storageService.setBool(AppConstants.onboardingCompletedKey, true);
    state = state.copyWith(isCompleted: true);
  }
  
  bool isOnboardingCompleted() {
    return _storageService.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }
  
  List<OnboardingPageModel> getOnboardingPages() {
    return [
      const OnboardingPageModel(
        title: 'onboarding_welcome',
        description: 'onboarding_welcome_description',
        imagePath: 'assets/images/onboarding_welcome.png',
        animationPath: 'assets/animations/welcome.json',
      ),
      const OnboardingPageModel(
        title: 'onboarding_track',
        description: 'onboarding_track_description',
        imagePath: 'assets/images/onboarding_track.png',
        animationPath: 'assets/animations/track.json',
      ),
      const OnboardingPageModel(
        title: 'onboarding_analyze',
        description: 'onboarding_analyze_description',
        imagePath: 'assets/images/onboarding_analyze.png',
        animationPath: 'assets/animations/analyze.json',
      ),
    ];
  }
}

class OnboardingState {
  final int currentPage;
  final bool isCompleted;
  final bool isLoading;
  
  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
    this.isLoading = false,
  });
  
  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref.read(storageServiceProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return getIt<StorageService>();
});
