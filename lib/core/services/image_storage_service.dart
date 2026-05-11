import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const int maxWidth = 550;
  static const int maxHeight = 220;
  static const _uuid = Uuid();

  /// Save an image file to the app's documents directory.
  /// Resizes to [maxWidth]x[maxHeight] if larger.
  /// Returns the local file path.
  Future<String> saveImage(File sourceFile) async {
    final dir = await _imageDir();
    final ext = p.extension(sourceFile.path).toLowerCase();
    final filename = '${_uuid.v4()}$ext';
    final destPath = p.join(dir.path, filename);

    final bytes = await sourceFile.readAsBytes();
    final resized = _resizeIfNeeded(bytes);

    final destFile = File(destPath);
    await destFile.writeAsBytes(resized);
    return destPath;
  }

  /// Save raw bytes (e.g. from Unsplash download) to the app's documents directory.
  Future<String> saveImageBytes(Uint8List bytes, {String ext = '.jpg'}) async {
    final dir = await _imageDir();
    final filename = '${_uuid.v4()}$ext';
    final destPath = p.join(dir.path, filename);

    final resized = _resizeIfNeeded(bytes);

    final destFile = File(destPath);
    await destFile.writeAsBytes(resized);
    return destPath;
  }

  /// Delete an image at [path] from local storage.
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get the File object for a stored image path.
  File getImageFile(String path) => File(path);

  Uint8List _resizeIfNeeded(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    if (decoded.width <= maxWidth) {
      return bytes;
    }

    // Only constrain width; height scales proportionally
    final resized = img.copyResize(decoded, width: maxWidth);

    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  Future<Directory> _imageDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(appDir.path, 'item_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }
}
