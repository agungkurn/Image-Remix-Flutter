part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(null) User? user,
    @Default(null) String? errorMessage,
  }) = _AuthState;
}
