import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:synqer_io/core/enums/filepick_type_enum.dart';

class AppPickedFile {
  final String name;

  final String path;

  final Uint8List? bytes;

  final int? size;

  final String? extension;

  final AppFileType type;

  const AppPickedFile({
    required this.name,
    required this.path,
    required this.type,
    this.bytes,
    this.size,
    this.extension,
  });

  File get file => File(path);

  bool get isImage => type == AppFileType.image;

  bool get isVideo => type == AppFileType.video;

  bool get isDocument => type == AppFileType.document;
}

class AppFilePicker {
  static final ImagePicker _imagePicker = ImagePicker();

  // ───────────────── IMAGE ─────────────────

  static Future<AppPickedFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (picked == null) return null;

      return AppPickedFile(
        name: picked.name,
        path: picked.path,
        bytes: await picked.readAsBytes(),
        size: await picked.length(),
        extension: picked.path.split('.').last,
        type: AppFileType.image,
      );
    } catch (e) {
      debugPrint('pickImage error: $e');
      return null;
    }
  }

  // ───────────────── VIDEO ─────────────────

  static Future<AppPickedFile?> pickVideo({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? picked = await _imagePicker.pickVideo(source: source);

      if (picked == null) return null;

      return AppPickedFile(
        name: picked.name,
        path: picked.path,
        bytes: null,
        size: await picked.length(),
        extension: picked.path.split('.').last,
        type: AppFileType.video,
      );
    } catch (e) {
      debugPrint('pickVideo error: $e');
      return null;
    }
  }

  // ───────────────── DOCUMENT ─────────────────

  static Future<AppPickedFile?> pickDocument({
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,

        allowedExtensions: allowedExtensions,

        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      return AppPickedFile(
        name: file.name,
        path: file.path ?? '',
        bytes: file.bytes,
        size: file.size,
        extension: file.extension,
        type: AppFileType.document,
      );
    } catch (e) {
      debugPrint('pickDocument error: $e');
      return null;
    }
  }

  // ───────────────── ALL FILES ─────────────────

  static Future<AppPickedFile?> pickAnyFile() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      final ext = file.extension?.toLowerCase() ?? '';

      AppFileType type = AppFileType.document;

      if (_imageExtensions.contains(ext)) {
        type = AppFileType.image;
      } else if (_videoExtensions.contains(ext)) {
        type = AppFileType.video;
      }

      return AppPickedFile(
        name: file.name,
        path: file.path ?? '',
        bytes: file.bytes,
        size: file.size,
        extension: file.extension,
        type: type,
      );
    } catch (e) {
      debugPrint('pickAnyFile error: $e');
      return null;
    }
  }

  // ───────────────── HELPERS ─────────────────

  static const List<String> _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ];

  static const List<String> _videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
  ];
}
