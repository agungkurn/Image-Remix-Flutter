part of 'navigation_bloc.dart';

@freezed
class NavigationEvent with _$NavigationEvent {
  const factory NavigationEvent.toImagePicker() = _ImagePickerNavigationEvent;

  const factory NavigationEvent.toImageViewer() = _ImagePreviewNavigationEvent;

  const factory NavigationEvent.toImageGenerator() =
      _ImageGeneratorNavigationEvent;
}
