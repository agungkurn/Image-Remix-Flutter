import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_bloc.freezed.dart';
part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState.toImagePicker()) {
    on<_ImagePickerNavigationEvent>(
      (event, emit) => emit(NavigationState.toImagePicker()),
    );
    on<_ImagePreviewNavigationEvent>(
      (event, emit) => emit(NavigationState.toImageViewer()),
    );
    on<_ImageGeneratorNavigationEvent>(
      (event, emit) => emit(NavigationState.toImageGenerator()),
    );
  }
}
