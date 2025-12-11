import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository {
  Future<Either<User, Exception>> signIn();
}

class DefaultAuthRepository extends AuthRepository {
  final FirebaseAuth _auth;

  DefaultAuthRepository({required FirebaseAuth auth}) : _auth = auth;

  User? get _currentUser => _auth.currentUser;

  @override
  Future<Either<User, Exception>> signIn() async {
    if (_currentUser != null) return Left(_currentUser!);

    try {
      final userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        return Left(userCredential.user!);
      } else {
        debugPrint('user null: ${userCredential.toString()}');
        return Right(Exception('Failed to create user'));
      }
    } catch (e) {
      debugPrint('error sign in: ${e.toString()}');
      return Right(Exception('Failed to create user'));
    }
  }
}
