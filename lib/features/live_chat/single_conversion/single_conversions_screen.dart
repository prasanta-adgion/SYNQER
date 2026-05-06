// ignore_for_file: deprecated_member_use

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_images.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/image_full_preview.dart';
import 'package:synqer_io/core/widgets/loading_screen.dart';
import 'package:synqer_io/features/live_chat/single_conversion/bloc/single_conversions_bloc.dart';
import 'package:synqer_io/features/live_chat/single_conversion/model/single_conversion_model.dart';
import 'package:synqer_io/features/live_chat/single_conversion/widgets/chat_appbar.dart';
import 'package:video_player/video_player.dart';

class SingleConversionsBlocProviderWrapper extends StatelessWidget {
  final String customerNumber, customerName;

  const SingleConversionsBlocProviderWrapper({
    super.key,
    required this.customerNumber,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SingleConversionsBloc(
            singleConversionRepo: AppInjector.singleConversionHistoryRepo,
          )..add(
            FetchSingleConversionsEvent(
              customerMobile: customerNumber,
              limit: 50,
            ),
          ),
      child: SingleChat(
        customerNumber: customerNumber,
        customerName: customerName,
      ),
    );
  }
}

class SingleChat extends StatefulWidget {
  final String customerNumber;
  final String customerName;

  const SingleChat({
    super.key,
    required this.customerNumber,
    required this.customerName,
  });

  @override
  State<SingleChat> createState() => _SingleChatState();
}

class _SingleChatState extends State<SingleChat> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;
  int _lastSendFailureId = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      // top reached in reverse list
      if (_scrollController.position.pixels != 0) {
        final state = context.read<SingleConversionsBloc>().state;

        if (state is SingleConversionsLoaded &&
            state.hasMore &&
            !state.isLoadingMore) {
          _loadMoreMessages();
        }
      }
    }
  }

  void _loadMoreMessages() {
    final state = context.read<SingleConversionsBloc>().state;

    if (state is! SingleConversionsLoaded) return;

    if (state.currentPage <= 1) return;

    context.read<SingleConversionsBloc>().add(
      LoadMoreSingleConversionsEvent(
        customerMobile: widget.customerNumber,
        limit: 50,
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String messageType) async {
    final text = _msgController.text.trim();

    if (text.isEmpty) return;

    _msgController.clear();

    context.read<SingleConversionsBloc>().add(
      SendSingleMessageEvent(
        customerMobile: widget.customerNumber,
        message: text,
        messageType: messageType,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                AppImages.chatBg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: c.bg),
              ),
            ),
          ),

          Column(
            children: [
              ChatAppbar(
                customerNumber: widget.customerNumber,
                customerName: widget.customerName,
              ),

              Expanded(
                child: BlocConsumer<SingleConversionsBloc, SingleConversionsState>(
                  listener: (context, state) {
                    if (state is SingleConversionsLoaded && !_initialized) {
                      _initialized = true;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      });
                    }

                    if (state is SingleConversionsLoaded &&
                        state.sendFailureMessage != null &&
                        state.sendFailureId != _lastSendFailureId) {
                      _lastSendFailureId = state.sendFailureId;

                      AppSnackbar.show(
                        context,
                        message: state.sendFailureMessage!,
                        type: SnackbarType.error,
                      );
                    }

                    if (state is SingleConversionsError) {
                      final errorMsg = state.errorMessage;

                      debugPrint("Error in send message: $errorMsg");

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMsg)));
                    }
                  },

                  builder: (context, state) {
                    if (state is SingleConversionsLoading) {
                      return const FullScreenLoader(
                        message: "Loading messages...",
                      );
                    }

                    if (state is SingleConversionsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: c.error),

                            const SizedBox(height: 16),

                            Text(
                              state.errorMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: c.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<SingleConversionsBloc>().add(
                                  FetchSingleConversionsEvent(
                                    customerMobile: widget.customerNumber,
                                    limit: 50,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SingleConversionsLoaded) {
                      if (state.conversions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: c.textMuted,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                "No messages yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // PERFORMANCE FIX
                      final reversedChats = state.conversions.reversed.toList();

                      return ListView.builder(
                        controller: _scrollController,

                        reverse: true,

                        padding: const EdgeInsets.symmetric(vertical: 10),

                        itemCount:
                            reversedChats.length +
                            (state.isLoadingMore ? 1 : 0),

                        itemBuilder: (context, index) {
                          if (index >= reversedChats.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    c.green,
                                  ),
                                ),
                              ),
                            );
                          }

                          final chat = reversedChats[index];

                          final isUser =
                              chat.direction?.toLowerCase().trim() ==
                              'outbound';

                          final currentDate = chat.createDate;

                          String? previousDate;

                          if (index < reversedChats.length - 1) {
                            previousDate = reversedChats[index + 1].createDate;
                          }

                          final showDateSeparator =
                              previousDate == null ||
                              currentDate != previousDate;

                          return Column(
                            children: [
                              if (showDateSeparator)
                                DateSeparator(date: currentDate),

                              InkWell(
                                onLongPress: () {
                                  print(
                                    "Delivered: ${chat.deliveredDate} ${chat.deliveredTime}\nRead: ${chat.readDate} ${chat.readTime}",
                                  );
                                },
                                child: ChatBubble(chat: chat, isUser: isUser),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(top: BorderSide(color: c.border, width: 1)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: MessageInputBar(
                      controller: _msgController,
                      onSend: () => sendMessage('text'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final SingleConversionModel chat;
  final bool isUser;

  const ChatBubble({super.key, required this.chat, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? c.green.withOpacity(0.15) : c.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUser
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                  bottomRight: isUser
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
                border: Border.all(
                  color: isUser ? c.green.withOpacity(0.3) : c.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  switch (chat.messageType) {
                    MessageType.text => Text(
                      chat.message ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: chat.isFailed ? c.error : c.textPrimary,
                        height: 1.4,
                        decoration: chat.isFailed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    MessageType.image => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageFullViewerScreen(
                              imageUrl: chat.mediaUrl.toString(),
                              title: chat.message.toString(),
                            ),
                          ),
                        );
                      },
                      child: ImagePreviewBubble(chat: chat),
                    ),
                    MessageType.video => VideoPlayerBubble(chat: chat),
                    MessageType.document => DocumentBubble(chat: chat),
                  },
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chat.createTime,
                        style: TextStyle(fontSize: 11, color: c.textMuted),
                      ),

                      if (isUser) ...[
                        const SizedBox(width: 4),

                        Builder(
                          builder: (_) {
                            if (chat.isFailed) {
                              return Icon(
                                Icons.error_outline,
                                size: 16,
                                color: c.error,
                              );
                            }

                            if (chat.isLocal) {
                              return SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: c.textMuted,
                                ),
                              );
                            }

                            return Icon(
                              chat.status == MessageStatus.read
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 16,
                              color: chat.status == MessageStatus.read
                                  ? c.green
                                  : c.textMuted,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewBubble extends StatelessWidget {
  final SingleConversionModel chat;

  const ImagePreviewBubble({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mediaUrl = chat.mediaUrl?.trim() ?? '';
    final caption = chat.message?.trim() ?? '';

    if (mediaUrl.isEmpty) {
      return _UnavailableMediaLabel(label: 'Image unavailable');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 180,
              maxWidth: 260,
              maxHeight: 260,
            ),
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  width: 220,
                  height: 180,
                  color: c.surfaceHigh,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.green,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 220,
                  height: 160,
                  color: c.surfaceHigh,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 42,
                    color: c.textMuted,
                  ),
                );
              },
            ),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            style: TextStyle(fontSize: 14, color: c.textPrimary, height: 1.35),
          ),
        ],
      ],
    );
  }
}

class VideoPlayerBubble extends StatefulWidget {
  final SingleConversionModel chat;

  const VideoPlayerBubble({super.key, required this.chat});

  @override
  State<VideoPlayerBubble> createState() => _VideoPlayerBubbleState();
}

class _VideoPlayerBubbleState extends State<VideoPlayerBubble> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  bool _hasError = false;

  String get _mediaUrl => widget.chat.mediaUrl?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chat.mediaUrl?.trim() != _mediaUrl) {
      _disposeControllers();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final mediaUrl = _mediaUrl;
    final uri = Uri.tryParse(mediaUrl);

    if (mediaUrl.isEmpty || uri == null || !uri.hasScheme) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final videoController = VideoPlayerController.networkUrl(uri);

      await videoController.initialize();

      if (!mounted || _mediaUrl != mediaUrl) {
        await videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        aspectRatio: videoController.value.aspectRatio,
      );

      setState(() {
        _videoController = videoController;
        _chewieController = chewieController;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = _fallbackTitle(widget.chat.message, 'Video');

    if (_hasError) {
      return _UnavailableMediaLabel(label: 'Video unavailable');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 240,
            height: 300,
            child: _isLoading || _chewieController == null
                ? Container(
                    color: Colors.black87,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.green,
                    ),
                  )
                : Chewie(controller: _chewieController!),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class DocumentBubble extends StatelessWidget {
  final SingleConversionModel chat;
  final VoidCallback? onTap;

  const DocumentBubble({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = _fallbackTitle(chat.message, 'Document');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.picture_as_pdf, color: c.error, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 18, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

class _UnavailableMediaLabel extends StatelessWidget {
  final String label;

  const _UnavailableMediaLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 18, color: c.textMuted),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14, color: c.textSecondary)),
      ],
    );
  }
}

String _fallbackTitle(String? value, String fallback) {
  final title = value?.trim() ?? '';

  return title.isEmpty ? fallback : title;
}

class DateSeparator extends StatelessWidget {
  final String date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Text(
          date,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
      ),
    );
  }
}

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: const InputDecoration(
                      hintText: "Message",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file_rounded),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        Material(
          color: c.green,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onSend,
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Center(child: Icon(Icons.send, color: c.onBrand)),
            ),
          ),
        ),
      ],
    );
  }
}
