part of 'image_generator_bloc.dart';

@freezed
class ImageGeneratorEvent with _$ImageGeneratorEvent {
  const factory ImageGeneratorEvent.pickImage(ImageSource source) = _PickImage;

  const factory ImageGeneratorEvent.removeImage() = _RemoveImage;

  const factory ImageGeneratorEvent.upload(String uid) = _Upload;

  const factory ImageGeneratorEvent.generate(String uid) = _Generate;

  const factory ImageGeneratorEvent.updateFromFirestore(
    Either<List<String>, Exception> firestoreResult,
  ) = _UpdateFromFirestore;
}
