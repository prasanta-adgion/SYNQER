// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart';
import 'package:video_player/video_player.dart';

class PhonePreview extends StatefulWidget {
  final String templateId;
  final String templateName;
  final String templateType;
  final IconData icon;
  final Map<String, String> variableValues;
  final TemplateData? initialTemplate;
  final ValueChanged<TemplateData>? onTemplateLoaded;

  const PhonePreview({
    super.key,
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.icon,
    this.variableValues = const {},
    this.initialTemplate,
    this.onTemplateLoaded,
  });

  @override
  State<PhonePreview> createState() => _PhonePreviewState();
}

class _PhonePreviewState extends State<PhonePreview> {
  @override
  Widget build(BuildContext context) {
    final initialTemplate = widget.initialTemplate;
    if (initialTemplate != null) {
      return TemplatePhonePreview(
        template: initialTemplate,
        title: widget.templateName,
        icon: widget.icon,
        variableValues: widget.variableValues,
      );
    }

    return FetchedPhonePreview(
      templateId: widget.templateId,
      templateName: widget.templateName,
      templateType: widget.templateType,
      icon: widget.icon,
      variableValues: widget.variableValues,
      onTemplateLoaded: widget.onTemplateLoaded,
    );
  }
}

class FetchedPhonePreview extends StatefulWidget {
  final String templateId;
  final String templateName;
  final String templateType;
  final IconData icon;
  final Map<String, String> variableValues;
  final ValueChanged<TemplateData>? onTemplateLoaded;

  const FetchedPhonePreview({
    super.key,
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.icon,
    this.variableValues = const {},
    this.onTemplateLoaded,
  });

  @override
  State<FetchedPhonePreview> createState() => _FetchedPhonePreviewState();
}

class _FetchedPhonePreviewState extends State<FetchedPhonePreview> {
  late Future<SingleTempleteDataModel> _templateFuture;

  @override
  void initState() {
    super.initState();
    _templateFuture = _fetchTemplate();
  }

  @override
  void didUpdateWidget(covariant FetchedPhonePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateId != widget.templateId) {
      setState(() {
        _templateFuture = _fetchTemplate();
      });
    }
  }

  Future<SingleTempleteDataModel> _fetchTemplate() {
    return AppInjector.rcsPreviewRepo.fetchTempleteById(widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return FutureBuilder<SingleTempleteDataModel>(
      future: _templateFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final template = snapshot.data?.data;

        if (template != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTemplateLoaded?.call(template);
          });
        }

        if (isLoading) {
          return _PhonePreviewFrame(
            icon: widget.icon,
            title: widget.templateName,
            child: _PhoneStatus(
              key: const ValueKey('loading'),
              message: 'Loading preview...',
              isLoading: true,
              color: c.primary,
            ),
          );
        }

        if (hasError || template == null) {
          return _PhonePreviewFrame(
            icon: widget.icon,
            title: widget.templateName,
            child: _PhoneStatus(
              key: const ValueKey('error'),
              message: 'Preview unavailable',
              icon: Icons.error_outline_rounded,
              color: c.error,
            ),
          );
        }

        return RcsPhonePreviewView(
          template: template,
          title: widget.templateName,
          icon: widget.icon,
          fallbackType: widget.templateType,
          variableValues: widget.variableValues,
        );
      },
    );
  }
}

class TemplatePhonePreview extends StatelessWidget {
  final TemplateData template;
  final String? title;
  final IconData icon;
  final Map<String, String> variableValues;

  const TemplatePhonePreview({
    super.key,
    required this.template,
    required this.icon,
    this.title,
    this.variableValues = const {},
  });

  @override
  Widget build(BuildContext context) {
    return RcsPhonePreviewView(
      template: template,
      title: title ?? template.name ?? 'Your Bot',
      icon: icon,
      fallbackType: template.type ?? '',
      variableValues: variableValues,
    );
  }
}

class LiveTemplatePhonePreview extends StatelessWidget {
  final TemplateData template;
  final String? title;
  final IconData icon;
  final Map<String, String> variableValues;

  const LiveTemplatePhonePreview({
    super.key,
    required this.template,
    required this.icon,
    this.title,
    this.variableValues = const {},
  });

  @override
  Widget build(BuildContext context) {
    return TemplatePhonePreview(
      template: template,
      title: title,
      icon: icon,
      variableValues: variableValues,
    );
  }
}

class RcsPhonePreviewView extends StatefulWidget {
  final TemplateData template;
  final String title;
  final IconData icon;
  final String fallbackType;
  final Map<String, String> variableValues;

  const RcsPhonePreviewView({
    super.key,
    required this.template,
    required this.title,
    required this.icon,
    this.fallbackType = '',
    this.variableValues = const {},
  });

  @override
  State<RcsPhonePreviewView> createState() => _RcsPhonePreviewViewState();
}

class _RcsPhonePreviewViewState extends State<RcsPhonePreviewView> {
  final ValueNotifier<int> _carouselIndex = ValueNotifier(0);

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _activeVideoUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RcsPhonePreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template != widget.template) {
      _disposeVideo();
      _carouselIndex.value = 0;
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    _carouselIndex.dispose();
    super.dispose();
  }

  Future<void> _setupVideo(String url) async {
    if (_activeVideoUrl == url && _chewieController != null) return;

    _disposeVideo();
    _activeVideoUrl = url;

    late final VideoPlayerController videoController;
    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController.initialize();
    } catch (_) {
      _activeVideoUrl = null;
      if (mounted) setState(() {});
      rethrow;
    }

    if (!mounted) {
      videoController.dispose();
      return;
    }

    _videoController = videoController;
    _chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF6257FF),
        handleColor: const Color(0xFF6257FF),
        bufferedColor: Colors.white38,
        backgroundColor: Colors.white12,
      ),
    );

    if (mounted) setState(() {});
  }

  void _disposeVideo() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _activeVideoUrl = null;
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePreviewFrame(
      icon: widget.icon,
      title: widget.title,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _TemplateBody(
          key: ValueKey(_templatePreviewKey(widget.template)),
          template: widget.template,
          fallbackName: widget.title,
          fallbackType: widget.fallbackType,
          carouselIndex: _carouselIndex,
          chewieController: _chewieController,
          setupVideo: _setupVideo,
          variableValues: widget.variableValues,
        ),
      ),
    );
  }
}

class _PhonePreviewFrame extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _PhonePreviewFrame({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 344,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF19192E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          _PhoneHeader(icon: icon, title: title),
          const SizedBox(height: 12),
          Expanded(child: child),
          const SizedBox(height: 10),
          _MessageSendButtonView(primaryColor: c.primary, iconColor: c.onBrand),
        ],
      ),
    );
  }
}

class _PhoneHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PhoneHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                AppConfig.currentTimeString(),
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
              const Spacer(),
              const Icon(
                Icons.more_horiz_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF6257FF),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'RCS Business',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white54, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateBody extends StatelessWidget {
  final TemplateData template;
  final String fallbackName;
  final String fallbackType;
  final ValueNotifier<int> carouselIndex;
  final ChewieController? chewieController;
  final Future<void> Function(String url) setupVideo;
  final Map<String, String> variableValues;

  const _TemplateBody({
    super.key,
    required this.template,
    required this.fallbackName,
    required this.fallbackType,
    required this.carouselIndex,
    required this.chewieController,
    required this.setupVideo,
    required this.variableValues,
  });

  @override
  Widget build(BuildContext context) {
    final type = (template.type ?? fallbackType).toLowerCase();

    if (type.contains('carousel') &&
        (template.carouselList?.isNotEmpty ?? false)) {
      return _CarouselPreview(
        cards: template.carouselList!,
        mediaUrls: template.mediaUrls ?? const [],
        carouselIndex: carouselIndex,
      );
    }

    if (template.standAlone != null) {
      final card = template.standAlone;
      return _RichCardPreview(
        title: card?.cardTitle ?? template.name ?? fallbackName,
        description: card?.cardDescription ?? template.textMessageContent ?? '',
        mediaUrl: _mediaUrl(card?.fileName, template.mediaUrls),
        suggestions: card?.suggestions ?? template.suggestions ?? const [],
        chewieController: chewieController,
        setupVideo: setupVideo,
      );
    }

    if (type.contains('text') ||
        (template.textMessageContent?.trim().isNotEmpty == true)) {
      return _TextPreview(
        title: template.name ?? fallbackName,
        message: template.textMessageContent ?? '',
        variables: template.templateDetails?.variables ?? const [],
        variableValues: variableValues,
        suggestions: template.suggestions ?? const [],
      );
    }

    return _RichCardPreview(
      title: template.name ?? fallbackName,
      description: template.textMessageContent ?? '',
      mediaUrl: _mediaUrl(null, template.mediaUrls),
      suggestions: template.suggestions ?? const [],
      chewieController: chewieController,
      setupVideo: setupVideo,
    );
  }
}

class _TextPreview extends StatelessWidget {
  final String title;
  final String message;
  final List<String> variables;
  final Map<String, String> variableValues;
  final List<SuggestionModel> suggestions;

  const _TextPreview({
    required this.title,
    required this.message,
    required this.variables,
    required this.variableValues,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.centerLeft,
          child: _MessageBubble(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.trim().isNotEmpty) ...[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  _messageWithVariableValues(
                    message,
                    variables,
                    variableValues,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
                _SuggestionButtons(suggestions: suggestions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RichCardPreview extends StatelessWidget {
  final String title;
  final String description;
  final String? mediaUrl;
  final List<SuggestionModel> suggestions;
  final ChewieController? chewieController;
  final Future<void> Function(String url) setupVideo;

  const _RichCardPreview({
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.suggestions,
    required this.chewieController,
    required this.setupVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: _MessageBubble(
          width: 250,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MediaPreview(
                url: mediaUrl,
                height: 102,
                chewieController: chewieController,
                setupVideo: setupVideo,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 8.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                    _SuggestionButtons(suggestions: suggestions),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselPreview extends StatelessWidget {
  final List<CarouselCard> cards;
  final List<String> mediaUrls;
  final ValueNotifier<int> carouselIndex;

  const _CarouselPreview({
    required this.cards,
    required this.mediaUrls,
    required this.carouselIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: cards.length,
            options: CarouselOptions(
              height: double.infinity,
              // viewportFraction: 0.70,
              padEnds: false,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
              onPageChanged: (index, _) => carouselIndex.value = index,
            ),
            itemBuilder: (context, index, realIndex) {
              final card = cards[index];

              return _MessageBubble(
                width: double.infinity,
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MediaPreview(
                      url: _mediaUrl(card.fileName, mediaUrls, index),
                      height: 90,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.cardTitle ?? 'Carousel item ${index + 1}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (card.cardDescription?.trim().isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 6),
                            Text(
                              card.cardDescription!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 7.5,
                                height: 1.2,
                              ),
                            ),
                          ],
                          _SuggestionButtons(
                            suggestions: card.suggestions ?? const [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),
        ValueListenableBuilder<int>(
          valueListenable: carouselIndex,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (index) {
                final isActive = index == value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: isActive ? 14 : 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white70 : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _MediaPreview extends StatefulWidget {
  final String? url;
  final double height;
  final ChewieController? chewieController;
  final Future<void> Function(String url)? setupVideo;

  const _MediaPreview({
    required this.url,
    required this.height,
    this.chewieController,
    this.setupVideo,
  });

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _maybeSetupVideo();
  }

  @override
  void didUpdateWidget(covariant _MediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _maybeSetupVideo();
  }

  Future<void> _maybeSetupVideo() async {
    final url = widget.url;
    if (url == null || !_isVideoUrl(url) || widget.setupVideo == null) return;
    setState(() => _videoFailed = false);
    try {
      await widget.setupVideo!(url);
    } catch (_) {
      if (mounted) setState(() => _videoFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url?.trim() ?? '';

    return Container(
      height: widget.height,
      width: double.infinity,
      color: const Color(0xFF050505),
      child: url.isEmpty
          ? const _EmptyMedia()
          : _isVideoUrl(url)
          ? _videoFailed
                ? const _EmptyMedia()
                : widget.chewieController == null
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ClipRect(child: Chewie(controller: widget.chewieController!))
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => const _MediaLoading(),
              errorWidget: (_, __, ___) => const _EmptyMedia(),
            ),
    );
  }
}

class _SuggestionButtons extends StatelessWidget {
  final List<SuggestionModel> suggestions;

  const _SuggestionButtons({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = suggestions
        .where(
          (suggestion) => suggestion.displayText?.trim().isNotEmpty == true,
        )
        .take(2)
        .toList();

    if (visibleSuggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: visibleSuggestions.map((suggestion) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              suggestion.displayText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6257FF),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;
  final EdgeInsetsGeometry? margin;

  const _MessageBubble({
    required this.child,
    this.width = 188,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 10),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      margin: margin ?? const EdgeInsets.only(right: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PhoneStatus extends StatelessWidget {
  final String message;
  final bool isLoading;
  final IconData icon;
  final Color color;

  const _PhoneStatus({
    super.key,
    required this.message,
    required this.color,
    this.isLoading = false,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: color, strokeWidth: 2),
            )
          else
            Icon(icon, color: color, size: 22),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MessageSendButtonView extends StatelessWidget {
  final Color primaryColor;
  final Color iconColor;

  const _MessageSendButtonView({
    required this.primaryColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 9,
            backgroundColor: primaryColor,
            child: Icon(Icons.send_rounded, color: iconColor, size: 10),
          ),
        ],
      ),
    );
  }
}

class _EmptyMedia extends StatelessWidget {
  const _EmptyMedia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
    );
  }
}

class _MediaLoading extends StatelessWidget {
  const _MediaLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
      ),
    );
  }
}

String? _mediaUrl(String? fileName, List<String>? mediaUrls, [int index = 0]) {
  final directFile = fileName?.trim();
  final safeIndex = mediaUrls != null && index < mediaUrls.length ? index : 0;
  final media = mediaUrls == null || mediaUrls.isEmpty
      ? null
      : mediaUrls[safeIndex].trim();

  if (directFile != null &&
      directFile.isNotEmpty &&
      _hasNetworkScheme(directFile)) {
    return directFile;
  }

  if (media != null && media.isNotEmpty) return media;

  return directFile == null || directFile.isEmpty ? null : directFile;
}

String _messageWithVariableValues(
  String message,
  List<String> variables,
  Map<String, String> values,
) {
  var resolvedMessage = message.trim().isNotEmpty
      ? message
      : variables.map((variable) => '[$variable]').join(' ');

  if (resolvedMessage.trim().isEmpty) return 'Text message template';

  for (final variable in variables) {
    final value = values[variable]?.trim();
    if (value == null || value.isEmpty) continue;

    for (final placeholder in _variablePlaceholders(variable)) {
      resolvedMessage = resolvedMessage.replaceAll(placeholder, value);
    }
  }

  return resolvedMessage;
}

bool _isVideoUrl(String url) {
  final normalized = url.toLowerCase().split('?').first;
  return normalized.endsWith('.mp4') ||
      normalized.endsWith('.mov') ||
      normalized.endsWith('.m4v') ||
      normalized.endsWith('.webm');
}

bool _hasNetworkScheme(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

List<String> _variablePlaceholders(String variable) {
  final trimmed = variable.trim();
  final plain = trimmed
      .replaceAll(RegExp(r'^\{\{|\}\}$'), '')
      .replaceAll(RegExp(r'^\[|\]$'), '')
      .replaceAll(RegExp(r'^\{|\}$'), '');

  return <String>{
    trimmed,
    plain,
    '[$plain]',
    '{$plain}',
    '{{$plain}}',
  }.toList();
}

String _templatePreviewKey(TemplateData template) {
  final suggestions = template.suggestions ?? const <SuggestionModel>[];
  final carouselCards = template.carouselList ?? const <CarouselCard>[];

  return Object.hashAll([
    template.id,
    template.name,
    template.type,
    template.textMessageContent,
    template.standAlone?.cardTitle,
    template.standAlone?.cardDescription,
    template.standAlone?.fileName,
    template.mediaUrls?.join('|'),
    template.templateDetails?.variables?.join('|'),
    ...suggestions.expand(
      (suggestion) => [
        suggestion.suggestionType,
        suggestion.displayText,
        suggestion.postback,
        suggestion.url,
        suggestion.phoneNumber,
      ],
    ),
    ...carouselCards.expand(
      (card) => [
        card.cardTitle,
        card.cardDescription,
        card.fileName,
        ...(card.suggestions ?? const <SuggestionModel>[]).expand(
          (suggestion) => [
            suggestion.suggestionType,
            suggestion.displayText,
            suggestion.postback,
            suggestion.url,
            suggestion.phoneNumber,
          ],
        ),
      ],
    ),
  ]).toString();
}
