part of 'image_generator_bloc.dart';

@freezed
class ImageGeneratorState with _$ImageGeneratorState {
  const factory ImageGeneratorState({
    @Default(null) File? originalImageFile,
    @Default(UiState.idle) UiState uploadState,
    @Default(UiState.idle) UiState generationState,
    @Default(null) String? originalImageUrl,
    @Default([]) List<String> generatedImageUrls,
    @Default(null) String? errorMessage,
  }) = _ImageGeneratorState;
}
