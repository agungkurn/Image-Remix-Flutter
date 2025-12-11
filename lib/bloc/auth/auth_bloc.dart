import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:redraw/repository/auth_repository.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthSignInAnonymously>((event, emit) => _onSignIn(event, emit));
  }

  void _onSignIn(AuthSignInAnonymously event, Emitter<AuthState> emit) async {
    final result = await _authRepository.signIn();
    result.fold(
      (user) {
        emit(state.copyWith(user: user, errorMessage: null));
      },
      (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      },
    );
  }
}
