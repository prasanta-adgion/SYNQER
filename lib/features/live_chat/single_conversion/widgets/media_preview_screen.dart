// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/enums/filepick_type_enum.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/any_file_picker.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/image_cropper.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final AppPickedFile file;
  final bool forChatScreen;
  final Function(AppPickedFile file, String caption) onSend;

  const MediaPreviewScreen({
    super.key,
    required this.file,
    required this.onSend,
    required this.forChatScreen,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();

  late AppPickedFile _currentFile;

  VideoPlayerController? _videoController;

  final _loadingVideo = ValueNotifier<bool>(false);
  final _chewieController = ValueNotifier<ChewieController?>(null);
  final _videoError = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _currentFile = widget.file;
    if (_currentFile.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _loadingVideo.value = true;
    try {
      _videoController = VideoPlayerController.file(File(_currentFile.path));
      await _videoController!.initialize();
      _chewieController.value = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
      );
    } catch (e) {
      debugPrint('Video preview error: $e');
      _videoError.value = true;
    } finally {
      _loadingVideo.value = false;
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _chewieController.value?.dispose();
    _chewieController.dispose();
    _loadingVideo.dispose();
    _videoError.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _send() {
    widget.onSend(_currentFile, _captionController.text.trim());
    Navigator.pop(context);
  }

  Future<void> _cropImage() async {
    if (!_currentFile.isImage) return;

    final croppedFile = await Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (_) => ImageCropperScreen(imageFile: File(_currentFile.path)),
      ),
    );

    if (croppedFile == null || !mounted) return;

    final croppedPath = croppedFile.path;
    final extension = _fileExtension(croppedPath) ?? 'jpg';
    final bytes = await croppedFile.readAsBytes();
    final size = await croppedFile.length();

    if (!mounted) return;

    setState(() {
      _currentFile = AppPickedFile(
        name: _fileName(croppedPath),
        path: croppedPath,
        bytes: bytes,
        size: size,
        extension: extension,
        type: AppFileType.image,
      );
    });
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last;
    return name.isEmpty ? 'cropped_image.jpg' : name;
  }

  String? _fileExtension(String path) {
    final name = _fileName(path);
    final dotIndex = name.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return null;
    }

    return name.substring(dotIndex + 1).toLowerCase();
  }

  // Future<void> _openDocument() async {
  //   final uri = Uri.file(widget.file.path);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   }
  // }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _documentIcon(String? ext) {
    return switch (ext?.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' => Icons.table_chart_rounded,
      'ppt' || 'pptx' => Icons.slideshow_rounded,
      'zip' || 'rar' || '7z' => Icons.folder_zip_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final title = _currentFile.isImage
        ? 'Image Preview'
        : _currentFile.isVideo
        ? 'Video Preview'
        : 'Document Preview';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: CustomAppBar(
        title: title,

        backgroundColor: c.surface,

        titleColor: c.textPrimary,

        subtitleColor: c.textSecondary,

        trailing: _currentFile.isImage
            ? IconButton(
                tooltip: 'Crop image',
                onPressed: _cropImage,
                icon: Icon(Icons.crop_rounded, color: c.textPrimary),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _buildPreview(c))),
            widget.forChatScreen
                ? _buildBottomBar(c)
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: AppButton(
                      text: 'Done',
                      onPressed: () {
                        widget.onSend(
                          _currentFile,
                          _captionController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                      bgColor: c.primary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(AppColors colors) {
    if (_currentFile.isImage) {
      return InteractiveViewer(
        child: Image.file(File(_currentFile.path), fit: BoxFit.contain),
      );
    }

    if (_currentFile.isVideo) {
      return ValueListenableBuilder<bool>(
        valueListenable: _loadingVideo,
        builder: (context, loading, _) {
          if (loading) {
            return CircularProgressIndicator(color: colors.primary);
          }

          return ValueListenableBuilder<ChewieController?>(
            valueListenable: _chewieController,
            builder: (context, chewie, _) {
              if (chewie == null) {
                return _buildErrorState(
                  colors,
                  Icons.videocam_off_rounded,
                  'Failed to load video',
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Chewie(controller: chewie),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // DOCUMENT
    return _buildDocumentPreview(colors);
  }

  Widget _buildDocumentPreview(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            child: Icon(
              _documentIcon(_currentFile.extension),
              size: 46,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            _currentFile.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 10),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(
                  label: _currentFile.extension?.toUpperCase() ?? 'FILE',
                  colors: colors,
                ),
                if (_currentFile.size != null) ...[
                  const SizedBox(width: 8),
                  _Chip(
                    label: _formatFileSize(_currentFile.size),
                    colors: colors,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppColors colors, IconData icon, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: colors.textMuted),
        const SizedBox(height: 14),
        Text(
          message,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppColors colors) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.inputBorder),
              ),
              child: TextField(
                controller: _captionController,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(color: colors.inputText, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Add caption...',
                  hintStyle: TextStyle(color: colors.inputHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: _send,
              borderRadius: BorderRadius.circular(30),
              child: const SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _Chip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
