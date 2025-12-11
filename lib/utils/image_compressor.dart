import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service untuk compress image sebelum upload
class ImageCompressor {
  // Constants untuk compression
  static const int maxWidth = 1536;
  static const int maxHeight = 1536;
  static const int quality = 85;
  static const int maxFileSizeKB = 2048; // 2MB target

  /// Compress image dari File
  /// Returns compressed File atau throw error
  static Future<File> compressImageFile(File imageFile) async {
    try {
      print('📸 Starting compression for: ${imageFile.path}');

      // Get original file size
      final originalSize = await imageFile.length();
      print('📦 Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');

      // Cek apakah file sudah cukup kecil
      if (originalSize <= maxFileSizeKB * 1024) {
        print('✅ File already small enough, skipping compression');
        return imageFile;
      }

      // Generate output path
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      // Check compressed size
      final compressedSize = await compressedFile.length();
      print(
        '✨ Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
      );
      print(
        '📉 Reduction: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(1)}%',
      );

      // Kalau masih terlalu besar, compress lagi dengan quality lebih rendah
      if (compressedSize > maxFileSizeKB * 1024) {
        print('⚠️ Still too large, compressing again with lower quality...');
        return await _compressAggressively(File(compressedFile.path));
      }

      return File(compressedFile.path);
    } catch (e) {
      print('❌ Compression error: $e');
      rethrow;
    }
  }

  /// Compress image dari Uint8List (misalnya dari camera)
  static Future<Uint8List> compressImageBytes(Uint8List imageBytes) async {
    try {
      print('📸 Starting compression for image bytes');
      print(
        '📦 Original size: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      // Cek apakah sudah cukup kecil
      if (imageBytes.length <= maxFileSizeKB * 1024) {
        print('✅ Image already small enough');
        return imageBytes;
      }

      // Compress
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      print(
        '✨ Compressed size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB',
      );
      print(
        '📉 Reduction: ${((1 - compressedBytes.length / imageBytes.length) * 100).toStringAsFixed(1)}%',
      );

      // Kalau masih terlalu besar, compress lagi
      if (compressedBytes.length > maxFileSizeKB * 1024) {
        print('⚠️ Still too large, compressing again...');
        return await _compressAggressivelyBytes(compressedBytes);
      }

      return compressedBytes;
    } catch (e) {
      print('❌ Compression error: $e');
      rethrow;
    }
  }

  /// Aggressive compression kalau file masih terlalu besar
  static Future<File> _compressAggressively(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'aggressive_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Turunkan quality dan size
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 70, // Lower quality
      minWidth: 1280, // Smaller size
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      throw Exception('Aggressive compression failed');
    }

    final size = await compressedFile.length();
    print(
      '✨ Aggressive compressed size: ${(size / 1024).toStringAsFixed(2)} KB',
    );

    return File(compressedFile.path);
  }

  /// Aggressive compression untuk bytes
  static Future<Uint8List> _compressAggressivelyBytes(
    Uint8List imageBytes,
  ) async {
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    print(
      '✨ Aggressive compressed size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB',
    );
    return compressedBytes;
  }

  /// Validate image file
  static Future<bool> isValidImageFile(File file) async {
    try {
      final fileSize = await file.length();

      // Max 20MB untuk original file
      if (fileSize > 20 * 1024 * 1024) {
        print('❌ File too large (>20MB)');
        return false;
      }

      // Check file extension
      final extension = path.extension(file.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.heic'].contains(extension)) {
        print('❌ Unsupported file format: $extension');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    }
  }

  /// Get image info tanpa load full image
  static Future<Map<String, dynamic>?> getImageInfo(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      // Simplified - you can use image package for actual dimensions
      return {
        'size': imageBytes.length,
        'sizeKB': (imageBytes.length / 1024).toStringAsFixed(2),
        'sizeMB': (imageBytes.length / 1024 / 1024).toStringAsFixed(2),
        'path': imageFile.path,
      };
    } catch (e) {
      print('❌ Failed to get image info: $e');
      return null;
    }
  }
}

/// Extension untuk memudahkan usage
extension FileCompression on File {
  Future<File> compress() => ImageCompressor.compressImageFile(this);

  Future<bool> isValidImage() => ImageCompressor.isValidImageFile(this);

  Future<Map<String, dynamic>?> getInfo() => ImageCompressor.getImageInfo(this);
}

extension BytesCompression on Uint8List {
  Future<Uint8List> compress() => ImageCompressor.compressImageBytes(this);
}
