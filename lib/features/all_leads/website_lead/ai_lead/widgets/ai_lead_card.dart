// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/helper_methods.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/model/ai_leads_model.dart';
import 'package:synqer_io/features/manage_contacts/widgets/delete_dailog.dart';

String _sanitize(String? s) {
  if (s == null) return '';
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final code = s.codeUnitAt(i);
    if (code >= 0xD800 && code <= 0xDBFF) {
      if (i + 1 < s.length) {
        final next = s.codeUnitAt(i + 1);
        if (next >= 0xDC00 && next <= 0xDFFF) {
          buf.write(s[i]);
          buf.write(s[i + 1]);
          i++;
          continue;
        }
      }
    } else if (code < 0xDC00 || code > 0xDFFF) {
      buf.write(s[i]);
    }
  }
  return buf.toString();
}

String _fmtPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) {
    final local = digits.substring(2);
    return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
  }
  if (digits.length == 10) {
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  return raw.isNotEmpty ? '+$raw' : '-';
}

class LeadCardTile extends StatelessWidget {
  final AiLeadsDataModel lead;
  final Future<void> Function()? onRefresh;

  const LeadCardTile({super.key, required this.lead, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sanitizedName = _sanitize(lead.name);
    final name = sanitizedName.isEmpty ? 'Unknown' : sanitizedName;
    final phone = _fmtPhone(lead.phone ?? '');
    final email = _sanitize(lead.email);
    final botName = _sanitize(lead.widgetConfigId?.botName);
    final notes = _sanitize(lead.notes);
    final dateTime = [
      lead.createdDate,
      lead.createdTime,
    ].where((value) => value != null && value.isNotEmpty).join(' ');

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(name: name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _MetaLine(icon: Icons.phone_outlined, text: phone),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _MetaLine(
                          icon: Icons.mail_outline_rounded,
                          text: email,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(isContacted: lead.isContacted == true),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                if (botName.isNotEmpty)
                  Flexible(child: _BotNameBadge(botName: botName)),
                const Spacer(),
                if (dateTime.isNotEmpty) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: c.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      dateTime,
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 13, color: c.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Actions ──
          Divider(height: 1, color: c.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "Edit",
                    icon: Icons.edit_outlined,
                    onPressed: () {},
                    bgColor: c.accentSoft,
                    textColor: c.primary,
                    iconColor: c.primary,
                    borderColor: c.primary.withOpacity(0.15),
                    borderWidth: 1,
                    btnHeight: 40,
                    borderRadius: 35,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: AppButton(
                    text: "Delete",
                    icon: Icons.delete_outline_rounded,
                    onPressed: () => _showDeleteDialog(context, lead),
                    bgColor: c.dangerSoft,
                    textColor: c.error,
                    iconColor: c.error,
                    borderColor: c.error.withOpacity(0.20),
                    borderWidth: 1,
                    btnHeight: 40,
                    borderRadius: 35,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AiLeadsDataModel lead) {
    final c = context.colors;

    final isDeleting = ValueNotifier(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDeleting,
          builder: (context, deleting, _) {
            return DeleteDialog(
              title: 'Delete AI Lead',

              message:
                  'Are you sure you want to delete "${lead.name ?? 'this lead'}"? This action cannot be undone.',

              confirmLabel: deleting ? 'Deleting...' : 'Delete',
              confirmColor: c.error,

              onConfirm: () async {
                if (deleting) return;

                isDeleting.value = true;

                try {
                  final response = await AppInjector.aiLeadRepository
                      .deleteAiWebLead(id: lead.sId.toString());

                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);

                  if (response['success'].toString() == 'true') {
                    AppSnackbar.show(
                      context,
                      message: 'AI Lead deleted successfully',
                      type: SnackbarType.success,
                    );

                    await onRefresh?.call();
                  } else {
                    AppSnackbar.show(
                      context,
                      message: response['message'] ?? 'Delete failed',
                      type: SnackbarType.error,
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);

                  AppSnackbar.show(
                    context,
                    message: 'Something went wrong',
                    type: SnackbarType.error,
                  );
                } finally {
                  isDeleting.dispose();
                }
              },
            );
          },
        );
      },
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 12, color: c.textMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  String get _initials =>
      AppHelperMethods.initialsNameCharacter(_sanitize(name));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isContacted;

  const _StatusBadge({required this.isContacted});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = isContacted ? c.successSoft : c.warningSoft;
    final fg = isContacted ? c.green : c.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isContacted
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
            size: 11,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            isContacted ? 'Contacted' : 'Pending',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotNameBadge extends StatelessWidget {
  final String botName;

  const _BotNameBadge({required this.botName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined, size: 11, color: c.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              botName,
              style: TextStyle(
                color: c.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
