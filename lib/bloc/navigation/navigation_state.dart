part of 'navigation_bloc.dart';

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState.toImagePicker() = ImagePickerNavigationState;

  const factory NavigationState.toImageViewer() = ImageViewerNavigationState;

  const factory NavigationState.toImageGenerator() =
      ImageGeneratorNavigationState;
}
