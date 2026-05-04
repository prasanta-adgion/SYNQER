// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_images.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/loading_screen.dart';
import 'package:synqer_io/features/single_conversion/bloc/single_conversions_bloc.dart';
import 'package:synqer_io/features/single_conversion/model/single_conversion_model.dart';
import 'package:synqer_io/features/single_conversion/widgets/chat_appbar.dart';

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
  final ValueNotifier<bool> _isSending = ValueNotifier(false);
  bool _initialized = false;

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
        // page: state.currentPage - 1,
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

    final bloc = context.read<SingleConversionsBloc>();

    // Save before clear
    final sendingText = text;

    // INSTANT UI UPDATE
    final localMessage = SingleConversionModel(
      message: sendingText,
      direction: "outbound",
      createDate: DateTime.now().toString().split(' ')[0],
      createTime: "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}",
      isRead: false,
    );

    bloc.addLocalMessage(localMessage);

    _msgController.clear();

    // Scroll to latest message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      _isSending.value = true;

      final response = await AppInjector.singleConversionHistoryRepo
          .sendMessage(
            customerMobile: widget.customerNumber,
            message: sendingText,
            messageType: messageType,
          );

      if (!mounted) return;

      if (response['success'] == true) {
        // SILENT BACKGROUND REFRESH
        bloc.add(
          SilentRefreshSingleConversionsEvent(
            customerMobile: widget.customerNumber,
            limit: 50,
          ),
        );
      } else {
        AppSnackbar.show(
          context,
          message: 'Failed to send message',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.show(
        context,
        message: 'Error in sending message',
        type: SnackbarType.error,
      );
    } finally {
      _isSending.value = false;
    }
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
                      isSending: _isSending,
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
                  Text(
                    chat.message ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: c.textPrimary,
                      height: 1.4,
                    ),
                  ),
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

                        Icon(
                          (chat.isRead ?? false) ? Icons.done_all : Icons.done,
                          size: 16,
                          color: (chat.isRead ?? false) ? c.green : c.textMuted,
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
          //   borderRadius: BorderRadius.circular(8),
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
  final ValueNotifier<bool> isSending;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isSending,
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
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        ValueListenableBuilder<bool>(
          valueListenable: isSending,
          builder: (context, value, child) {
            return Material(
              color: c.green,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: value ? null : onSend,
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: value
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onBrand,
                            ),
                          )
                        : Icon(Icons.send, color: c.onBrand),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
