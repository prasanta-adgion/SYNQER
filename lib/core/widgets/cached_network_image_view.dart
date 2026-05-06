import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedNetworkImageView extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color backgroundColor;
  final double? defaultIconSIze;
  final Widget? defaultImage;

  const CachedNetworkImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.defaultIconSIze,
    this.defaultImage,
  });

  bool get _hasValidUrl =>
      imageUrl != null &&
      imageUrl!.trim().isNotEmpty &&
      Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: _hasValidUrl
            ? CachedNetworkImage(
                imageUrl: imageUrl!.trim(),
                width: width,
                height: height,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 150),

                placeholder: (_, _) => placeholder ?? _defaultPlaceholder(),

                /// UI fallback
                errorWidget: (_, _, _) => errorWidget ?? _defaultError(),

                /// Silence 404 spam
                errorListener: (error) {},
              )
            : _defaultError(),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultError() {
    return Center(
      child:
          defaultImage ??
          Icon(
            Icons.image_not_supported_outlined,
            size: defaultIconSIze ?? 24,
            color: Colors.grey,
          ),
    );
  }
}
