// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';

class ImageCropperScreen extends StatefulWidget {
  const ImageCropperScreen({super.key, required this.imageFile});

  /// The source image to be cropped.
  final File imageFile;

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  File? _croppedFile;
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Launch the native cropper as soon as the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) => _cropImage());
  }

  Future<void> _cropImage() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final c = context.colors;

      final cropped = await ImageCropper().cropImage(
        sourcePath: widget.imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: c.surface,
            toolbarWidgetColor: c.textPrimary,
            statusBarColor: c.surface,
            backgroundColor: c.surface,
            activeControlsWidgetColor: c.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            aspectRatioPresets: const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (!mounted) return;

      if (cropped == null) {
        // User cancelled the native cropper — close this screen.
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        _croppedFile = File(cropped.path);
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to crop image: $e';
        _isProcessing = false;
      });
    }
  }

  void _onSave() {
    if (_croppedFile != null) {
      Navigator.of(context).pop(_croppedFile);
    }
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Image Cropper',
        subtitle: 'Crop your picked image.',
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _buildPreview(c)),
              const SizedBox(height: 16),
              _buildActions(c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(dynamic c) {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: c.primary),
            const SizedBox(height: 16),
            Text(
              'Opening cropper...',
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: c.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _cropImage,
              icon: Icon(Icons.refresh, color: c.primary),
              label: Text('Try again', style: TextStyle(color: c.primary)),
            ),
          ],
        ),
      );
    }

    if (_croppedFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.textSecondary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.file(
                  _croppedFile!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: c.surface.withOpacity(0.9),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _cropImage,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.crop, color: c.textPrimary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(dynamic c) {
    final canSave = _croppedFile != null && !_isProcessing;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : _onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: c.textSecondary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canSave ? _onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: c.primary.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check, size: 18),
            label: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
