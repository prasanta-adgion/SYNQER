// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/live_conversions/model/live_conversions_model.dart';

class ConversionsCardTile extends StatelessWidget {
  final ConversionsChatData chat;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;

  const ConversionsCardTile({
    super.key,
    required this.chat,
    this.onTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final name = (chat.customerName?.trim().isNotEmpty ?? false)
        ? chat.customerName!
        : (chat.customerMobile ?? 'Unknown');

    final hasUnread = (chat.unreadCount ?? 0) > 0;
    final isOutgoing =
        chat.lastDirection?.toLowerCase() == 'outbound' ||
        chat.lastDirection?.toLowerCase() == 'out';

    return Slidable(
      key: ValueKey(chat.customerMobile ?? name),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onCallTap?.call(),
            backgroundColor: c.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.call_rounded, size: 22),
                SizedBox(height: 4),
                Text(
                  'Call',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Material(
        color: c.surface,
        child: InkWell(
          onTap: onTap,
          splashColor: c.primary.withOpacity(0.06),
          highlightColor: c.primary.withOpacity(0.04),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Avatar ──────────────────────────────────────────────
                    _Avatar(name: name, isUnread: hasUnread, colors: c),
                    const SizedBox(width: 12),

                    // ── Middle: name + last message ─────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 15,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                isOutgoing
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 15,
                                color: isOutgoing ? c.primary : c.green,
                              ),
                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  chat.lastMessage?.trim().isNotEmpty == true
                                      ? chat.lastMessage!
                                      : 'No messages yet',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: hasUnread
                                        ? c.textPrimary
                                        : c.textSecondary,
                                    fontSize: 13,
                                    height: 1.3,
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ── Right: time + unread badge ──────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chat.date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 2),
                        if (hasUnread)
                          _UnreadBadge(
                            count: chat.unreadCount!,
                            // count: 5,
                            color: c.primary,
                          )
                        else
                          Text(
                            chat.time,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: hasUnread ? c.primary : c.textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 78),
                child: Divider(height: 1, thickness: 0.6, color: c.border),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Avatar — circular initials avatar tinted with brand color
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final bool isUnread;
  final dynamic colors; // AppColors — typed loosely to avoid extra import here

  const _Avatar({
    required this.name,
    required this.isUnread,
    required this.colors,
  });

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [c.primary, c.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          color: c.onBrand,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UnreadBadge — pill that scales between 1-2 digit and 3+ digit counts
// ─────────────────────────────────────────────────────────────────────────────

class _UnreadBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _UnreadBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final display = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c.onBrand,
          height: 1,
        ),
      ),
    );
  }
}
