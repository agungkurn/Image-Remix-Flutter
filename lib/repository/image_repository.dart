import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:redraw/utils/image_compressor.dart';

abstract class ImageRepository {
  File? originalImageFile;
  String? originalImageUrl;
  List<String> generatedImageUrls = List.empty();

  Future<Either<String, Exception>> upload(String uid);

  Future<Either<String, Exception>> triggerCloudFunction(String uid);

  void getFirestoreUpdate(
    String uid,
    String generationId,
    Function(Either<List<String>, Exception>) onUpdated,
  );

  void stopSnapshot();
}

class DefaultImageRepository implements ImageRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  String _uploadId = DateTime.now().millisecondsSinceEpoch.toString();

  StreamSubscription? _sub;

  DefaultImageRepository({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _functions = functions,
       _storage = storage;

  @override
  List<String> generatedImageUrls = List.empty();

  @override
  File? originalImageFile;

  @override
  String? originalImageUrl;

  @override
  Future<Either<String, Exception>> upload(String uid) async {
    if (originalImageFile == null) return Right(Exception('image is null'));

    _uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    final compressed = await _compressImage(originalImageFile!);

    if (compressed == null) return Right(Exception('invalid image'));

    try {
      final ref = _storage.ref().child('users/$uid/original/$_uploadId.jpg');

      debugPrint('upload: $_uploadId');

      await ref.putFile(compressed);
      return Left(await ref.getDownloadURL());
    } on Exception catch (e) {
      debugPrint('error upload: ${e.toString()}');
      return Right(e);
    }
  }

  @override
  Future<Either<String, Exception>> triggerCloudFunction(String uid) async {
    try {
      debugPrint('generate: $_uploadId');
      final callable = _functions.httpsCallable('generateImages');
      final result = await callable.call({
        'uid': uid,
        'uploadId': _uploadId,
        'forTesting': false,
      });

      return Left(result.data['generationId']);
    } on FirebaseFunctionsException catch (e) {
      return Right(
        e.message?.isNotEmpty == true ? e : Exception('Something went wrong'),
      );
    } on Exception catch (e) {
      debugPrint('error functions: ${e.toString()}');
      return Right(e);
    }
  }

  @override
  Future<void> getFirestoreUpdate(
    String uid,
    String generationId,
    Function(Either<List<String>, Exception>) onUpdated,
  ) async {
    Either<List<String>, Exception> either = Left(List.empty());

    final doc = _firestore
        .collection("users")
        .doc(uid)
        .collection("generations")
        .doc(generationId);

    _sub = doc.snapshots().listen(
      (snap) async {
        debugPrint('firestore: ${snap.data()}');

        if (snap.exists) {
          final data = snap.data()!;
          final paths = List<String>.from(data['generatedPaths'] ?? []);
          final urls = await _resolveDownloadUrls(paths);

          either = Left(urls);
        } else {
          either = Right(Exception("Data doesn't exist"));
        }

        onUpdated(either);
      },
      onError: (e) {
        debugPrint('error firestore: ${e.toString()}');
        either = Right(e);
        onUpdated(either);
      },
    );
  }

  @override
  void stopSnapshot() {
    _sub?.cancel();
  }

  Future<File?> _compressImage(File image) async {
    final isValid = await image.isValidImage() == true;
    if (!isValid) {
      return null;
    }

    try {
      final compressed = await image.compress();
      return compressed;
    } catch (e) {
      debugPrint('failed to compress: $e');
      rethrow;
    }
  }

  Future<List<String>> _resolveDownloadUrls(List<String> paths) async =>
      Future.wait(paths.map((p) => _storage.ref().child(p).getDownloadURL()));
}
