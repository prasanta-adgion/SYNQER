import 'package:flutter/material.dart';
import 'package:synqer_io/core/widgets/cached_network_image_view.dart';

class ImageFullViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;

  const ImageFullViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  State<ImageFullViewerScreen> createState() => ImageFullViewerScreenState();
}

class ImageFullViewerScreenState extends State<ImageFullViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isReset = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _isReset = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              "Pinch to zoom • Double-tap to reset",
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Reset zoom
          AnimatedOpacity(
            opacity: _isReset ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.zoom_out_map_rounded, size: 22),
              tooltip: "Reset zoom",
              onPressed: _resetZoom,
            ),
          ),
          // Download
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 22),
            tooltip: "Download",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Downloading ${widget.title}…"),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color(0xFF1E1E1E),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: _resetZoom,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 6.0,
          onInteractionEnd: (_) {
            final isIdentity =
                _transformationController.value == Matrix4.identity();
            if (_isReset != isIdentity) setState(() => _isReset = isIdentity);
          },
          child: Center(
            child: Hero(
              tag: widget.imageUrl,
              child: CachedNetworkImageView(
                imageUrl: widget.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                backgroundColor: Colors.transparent,
                defaultImage: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white24,
                        size: 64,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Image unavailable",
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
