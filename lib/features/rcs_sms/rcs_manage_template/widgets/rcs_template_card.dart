import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_popover_dailog.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';

class RcsTemplateCard extends StatelessWidget {
  final RcsTemplateDataModel template;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const RcsTemplateCard({
    super.key,
    required this.template,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final category = template.templateDetails?.category ?? '';
    final formattedDate = _formatDate(template.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: c.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name.isNotEmpty ? template.name : 'Untitled',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          category,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Builder(
                  builder: (buttonContext) => InkWell(
                    onTap: () => _showMenu(context, buttonContext),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.more_vert,
                        color: c.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (template.textMessageContent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                template.textMessageContent,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Divider(height: 1, thickness: 0.6, color: c.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _StatusBadge(status: template.status),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: c.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, BuildContext buttonContext) {
    AppPopoverMenu.show(
      context: context,
      buttonContext: buttonContext,
      width: 180,
      items: [
        AppPopoverItem(
          title: 'View',
          icon: Icons.visibility_outlined,
          onTap: onView,
        ),
        AppPopoverItem(
          title: 'Delete',
          icon: Icons.delete_outline,
          isDestructive: true,
          onTap: onDelete,
        ),
      ],
    );
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final normalized = status.toLowerCase();

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (normalized) {
      case 'approved':
        bgColor = c.successSoft;
        textColor = c.green;
        icon = Icons.check_circle_outline;
      case 'rejected':
        bgColor = c.dangerSoft;
        textColor = c.error;
        icon = Icons.cancel_outlined;
      default:
        bgColor = c.warningSoft;
        textColor = c.warning;
        icon = Icons.access_time_outlined;
    }

    final label = status.isNotEmpty
        ? '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}'
        : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
