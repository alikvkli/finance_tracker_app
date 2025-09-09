import 'package:equatable/equatable.dart';

class OnboardingPageModel extends Equatable {
  final String title;
  final String description;
  final String imagePath;
  final String animationPath;
  
  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.animationPath,
  });
  
  @override
  List<Object?> get props => [title, description, imagePath, animationPath];
}
