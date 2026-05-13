// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_configarations.dart';
import 'package:synqer_io/core/utils/helper_methods.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_popover_dailog.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/widgets/edit_lead_data.dart';
import 'package:synqer_io/features/live_chat/single_conversion/single_conversions_screen.dart';
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
    } else if (code >= 0xDC00 && code <= 0xDFFF) {
      // unpaired low surrogate — skip
    } else {
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
  return raw.isNotEmpty ? '+$raw' : '—';
}

String _phoneForDial(String raw) => raw.replaceAll(RegExp(r'\D'), '');

String _phoneForWhatsApp(String raw) {
  final digits = _phoneForDial(raw);
  if (digits.length == 10) return '91$digits';
  return digits;
}

class LeadCardTile extends StatelessWidget {
  final WhatsappLeadsDataModel lead;
  final Future<void> Function()? onRefresh;

  const LeadCardTile({super.key, required this.lead, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sanitizedName = _sanitize(lead.name);
    final name = sanitizedName.isEmpty ? 'Unknown' : sanitizedName;
    final phone = _fmtPhone(lead.phoneNumber ?? '');
    final leadType = lead.leadType ?? '';
    final status = lead.status ?? '';
    final remark = _sanitize(lead.remark);
    final queries = (lead.query ?? [])
        .whereType<String>()
        .map(_sanitize)
        .where((s) => s.isNotEmpty)
        .toList();
    final date = lead.enquiryDate ?? '';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: avatar + name/phone + status ──
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
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 12,
                              color: c.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status.isNotEmpty) _StatusBadge(status: status),
                    const SizedBox(width: 6),
                    Builder(
                      builder: (buttonContext) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showActionsPopover(
                            context: context,
                            buttonContext: buttonContext,
                            lead: lead,
                          ),
                          child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.surfaceHigh,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.border),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: c.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: c.border),

          // ── Meta: lead type + enquiry date ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                if (leadType.isNotEmpty) _LeadTypeBadge(type: leadType),
                const Spacer(),
                if (date.isNotEmpty) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: c.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Queries ──
          if (queries.isNotEmpty) ...[
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUERIES',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...queries.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              q,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Remark ──
          if (remark.isNotEmpty) ...[
            Divider(height: 1, color: c.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 13, color: c.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      remark,
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
                    text: 'WhatsApp',
                    // icon: Icons.chat_outlined,
                    iconWidget: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                    ),
                    onPressed: () => _openWhatsApp(context, lead),
                    bgColor: c.successSoft,
                    textColor: c.green,
                    iconColor: c.green,
                    borderColor: c.green.withOpacity(0.20),
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
                    text: 'Call',
                    icon: Icons.call_outlined,
                    onPressed: () => _callLead(context, lead),
                    bgColor: c.accentSoft,
                    textColor: c.primary,
                    iconColor: c.primary,
                    borderColor: c.primary.withOpacity(0.20),
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

  Future<void> _openWhatsApp(
    BuildContext context,
    WhatsappLeadsDataModel lead,
  ) async {
    final phone = _phoneForWhatsApp(lead.phoneNumber ?? '');
    if (phone.isEmpty) {
      AppSnackbar.show(
        context,
        message: 'Phone number not available',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      // await AppConfig.openWebsite('https://wa.me/$phone');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleConversionsBlocProviderWrapper(
            customerNumber: phone.toString(),
            customerName: lead.name ?? '',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.show(
        context,
        message: 'Could not open WhatsApp',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _callLead(
    BuildContext context,
    WhatsappLeadsDataModel lead,
  ) async {
    final phone = _phoneForDial(lead.phoneNumber ?? '');
    if (phone.isEmpty) {
      AppSnackbar.show(
        context,
        message: 'Phone number not available',
        type: SnackbarType.error,
      );
      return;
    }

    await AppConfig.launchCaller(phone);
  }

  void _showActionsPopover({
    required BuildContext context,
    required BuildContext buttonContext,
    required WhatsappLeadsDataModel lead,
  }) {
    final c = context.colors;

    AppPopoverMenu.show(
      context: context,
      buttonContext: buttonContext,
      width: 180,
      items: [
        AppPopoverItem(
          title: 'Edit',
          icon: Icons.edit_outlined,
          iconColor: c.primary,
          onTap: () => _showEditDialog(context, lead),
        ),
        AppPopoverItem(
          title: 'Delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: () => _showDeleteDialog(context, lead),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, WhatsappLeadsDataModel lead) {
    EditLeadBottomSheet.show(context, lead, onRefresh: onRefresh);
  }

  void _showDeleteDialog(BuildContext context, WhatsappLeadsDataModel lead) {
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
              title: 'Delete Lead',
              message:
                  'Are you sure you want to delete "${lead.name ?? 'this lead'}"? This action cannot be undone.',

              confirmLabel: deleting ? 'Deleting...' : 'Delete',
              confirmColor: c.error,

              onConfirm: () async {
                if (deleting) return;

                isDeleting.value = true;

                try {
                  final response = await AppInjector.whatsappLeadsRepo
                      .deleteLead(leadId: lead.sId.toString());

                  if (!context.mounted) return;

                  Navigator.pop(dialogContext);

                  if (response['success'].toString() == 'true') {
                    AppSnackbar.show(
                      context,
                      message: 'Lead deleted successfully',
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

// ─── Avatar ──────────────

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

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = _colors(c);
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
          Icon(_icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            _displayStatus,
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

  // API returns "Follow+Up" / "Not+Interested" — normalize for display
  String get _displayStatus => status.replaceAll('+', ' ');

  (Color, Color) _colors(dynamic c) {
    final normalized = status.replaceAll('+', ' ');
    return switch (normalized) {
      'Pending' => (c.warningSoft as Color, c.warning as Color),
      'Follow Up' => (c.accentSoft as Color, c.primary as Color),
      'Interested' => (c.successSoft as Color, c.green as Color),
      'Not Interested' => (c.dangerSoft as Color, c.error as Color),
      'Closed' => (c.surfaceHigh as Color, c.textSecondary as Color),
      _ => (c.surfaceHigh as Color, c.textSecondary as Color),
    };
  }

  IconData get _icon {
    final normalized = status.replaceAll('+', ' ');
    return switch (normalized) {
      'Pending' => Icons.schedule_rounded,
      'Follow Up' => Icons.phone_callback_rounded,
      'Interested' => Icons.thumb_up_outlined,
      'Not Interested' => Icons.thumb_down_outlined,
      'Closed' => Icons.check_circle_outline_rounded,
      _ => Icons.info_outline_rounded,
    };
  }
}

// ─── Lead type badge ──────────────────────────────────────────────────────────

class _LeadTypeBadge extends StatelessWidget {
  final String type;
  const _LeadTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final normalized = type.replaceAll('+', ' ').toLowerCase();
    final isLead = normalized == 'lead';
    final bg = isLead ? c.accentSoft : const Color(0x26413D81);
    final fg = isLead ? c.primary : const Color(0xFF413D81);
    final label = isLead ? 'Lead' : 'General Enquiry';
    final icon = isLead
        ? Icons.person_outline_rounded
        : Icons.chat_bubble_outline_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────
