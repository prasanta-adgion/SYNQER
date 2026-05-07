import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/utils/any_file_picker.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final AppPickedFile file;

  final Function(AppPickedFile file, String caption) onSend;

  const MediaPreviewScreen({
    super.key,
    required this.file,
    required this.onSend,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();

  VideoPlayerController? _videoController;

  ChewieController? _chewieController;

  bool _loadingVideo = false;

  @override
  void initState() {
    super.initState();

    if (widget.file.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() => _loadingVideo = true);

      _videoController = VideoPlayerController.file(File(widget.file.path));

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,

        autoPlay: true,

        looping: false,

        allowFullScreen: true,

        allowMuting: true,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video preview error: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingVideo = false);
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();

    _chewieController?.dispose();

    _videoController?.dispose();

    super.dispose();
  }

  void _send() {
    widget.onSend(widget.file, _captionController.text.trim());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text('Preview', style: TextStyle(color: Colors.white)),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _buildPreview())),

            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),

              decoration: BoxDecoration(
                color: Colors.black,

                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: TextField(
                        controller: _captionController,

                        minLines: 1,
                        maxLines: 4,

                        style: const TextStyle(color: Colors.white),

                        decoration: InputDecoration(
                          hintText: 'Add caption...',

                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),

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
                    color: const Color(0xFF22C55E),

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    // IMAGE
    if (widget.file.isImage) {
      return InteractiveViewer(
        child: Image.file(File(widget.file.path), fit: BoxFit.contain),
      );
    }

    // VIDEO
    if (widget.file.isVideo) {
      if (_loadingVideo) {
        return const CircularProgressIndicator(color: Colors.white);
      }

      if (_chewieController == null) {
        return const Text(
          'Failed to load video',

          style: TextStyle(color: Colors.white),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(12),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,

            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }

    // DOCUMENT
    return Container(
      margin: const EdgeInsets.all(24),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.description_rounded, size: 64, color: Colors.white),

          const SizedBox(height: 16),

          Text(
            widget.file.name,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 15,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.file.extension?.toUpperCase() ?? 'FILE',

            style: TextStyle(
              color: Colors.white.withOpacity(0.6),

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
