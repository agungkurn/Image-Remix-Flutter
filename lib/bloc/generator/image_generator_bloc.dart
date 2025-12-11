import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redraw/repository/image_repository.dart';
import 'package:redraw/utils/ui_state.dart';

part 'image_generator_bloc.freezed.dart';
part 'image_generator_event.dart';
part 'image_generator_state.dart';

class ImageGeneratorBloc
    extends Bloc<ImageGeneratorEvent, ImageGeneratorState> {
  final ImageRepository _repository;
  final ImagePicker _imagePicker;

  ImageGeneratorBloc({
    required ImagePicker imagePicker,
    required ImageRepository repository,
  }) : _imagePicker = imagePicker,
       _repository = repository,
       super(const ImageGeneratorState()) {
    on<_PickImage>((event, emit) => _onPickImage(event.source, emit));
    on<_RemoveImage>((event, emit) => _onRemoveImage(emit));
    on<_Upload>((event, emit) => _onUpload(event, emit));
    on<_Generate>((event, emit) => _onGenerate(event, emit));
    on<_UpdateFromFirestore>((event, emit) => _onFirestoreUpdate(event, emit));
  }

  @override
  Future<void> close() {
    _repository.stopSnapshot();
    return super.close();
  }

  void _onPickImage(
    ImageSource source,
    Emitter<ImageGeneratorState> emit,
  ) async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      _repository.originalImageFile = File(pickedFile.path);
      emit(
        ImageGeneratorState(originalImageFile: _repository.originalImageFile),
      );
    }
  }

  void _onRemoveImage(Emitter<ImageGeneratorState> emit) {
    _repository.originalImageFile = null;
    emit(ImageGeneratorState());
  }

  Future<void> _onUpload(
    _Upload event,
    Emitter<ImageGeneratorState> emit,
  ) async {
    emit(state.copyWith(uploadState: UiState.loading, errorMessage: null));

    try {
      final uploadResult = await _repository.upload(event.uid);
      uploadResult.fold(
        (originalUrl) {
          emit(
            state.copyWith(
              uploadState: UiState.success,
              originalImageUrl: originalUrl,
            ),
          );
        },
        (e) {
          emit(
            state.copyWith(
              uploadState: UiState.error,
              errorMessage: 'An error occurred',
            ),
          );
        },
      );

      add(ImageGeneratorEvent.generate(event.uid));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), uploadState: UiState.error),
      );
    }
  }

  Future<void> _onGenerate(
    _Generate event,
    Emitter<ImageGeneratorState> emit,
  ) async {
    emit(state.copyWith(generationState: UiState.loading, errorMessage: null));

    try {
      final triggerCloudResult = await _repository.triggerCloudFunction(
        event.uid,
      );
      triggerCloudResult.fold(
        (generationId) {
          _repository.getFirestoreUpdate(event.uid, generationId, (
            firestoreResult,
          ) {
            add(ImageGeneratorEvent.updateFromFirestore(firestoreResult));
          });
        },
        (e) {
          emit(
            state.copyWith(
              generationState: UiState.error,
              errorMessage: e.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          generationState: UiState.error,
        ),
      );
    }
  }

  Future<void> _onFirestoreUpdate(
    _UpdateFromFirestore event,
    Emitter<ImageGeneratorState> emit,
  ) async {
    emit(state.copyWith(generationState: UiState.success));

    event.firestoreResult.fold(
      (data) {
        emit(
          state.copyWith(
            generatedImageUrls: data,
            generationState: UiState.success,
          ),
        );
      },
      (e) {
        emit(
          state.copyWith(
            errorMessage: e.toString(),
            generationState: UiState.error,
          ),
        );
      },
    );
  }
}
