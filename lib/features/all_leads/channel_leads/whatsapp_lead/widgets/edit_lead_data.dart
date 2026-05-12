import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/helper_methods.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/all_leads/channel_leads/whatsapp_lead/model/whatsappleads_data_model.dart';

String? _mapStatus(String? raw) {
  switch (raw) {
    case null:
    case 'All':
      return null;
    case 'Follow Up':
      return 'Follow Up';
    // case 'Not Interested':
    //   return 'Not+Interested';
    default:
      return raw;
  }
}

String? _mapLeadType(String? raw) {
  switch (raw) {
    case null:
    case 'All':
      return null;
    case 'General Enquiry':
      return 'general enquiry';
    case 'Lead':
      return 'lead';
    default:
      return null;
  }
}

class EditLeadBottomSheet extends StatefulWidget {
  final WhatsappLeadsDataModel lead;
  final Future<void> Function()? onRefresh;

  const EditLeadBottomSheet({
    super.key,
    required this.lead,
    required this.onRefresh,
  });

  static Future<void> show(
    BuildContext context,
    WhatsappLeadsDataModel lead, {
    required final Future<void> Function()? onRefresh,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SafeArea(
        child: EditLeadBottomSheet(lead: lead, onRefresh: onRefresh),
      ),
    );
  }

  @override
  State<EditLeadBottomSheet> createState() => _EditLeadBottomSheetState();
}

class _EditLeadBottomSheetState extends State<EditLeadBottomSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _remarkCtrl;
  late String _selectedStatus;
  late String _selectedLeadType;

  final ValueNotifier<bool> _isUpdating = ValueNotifier(false);

  static const _statuses = [
    'Pending',
    'Follow Up',
    'Interested',
    'Not Interested',
    'Closed',
  ];
  static const _leadTypes = ['Lead', 'General Enquiry'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lead.name ?? '');
    _remarkCtrl = TextEditingController(text: widget.lead.remark ?? '');
    _selectedStatus = (widget.lead.status ?? 'Pending').replaceAll('+', ' ');
    final raw = (widget.lead.leadType ?? '').replaceAll('+', ' ').toLowerCase();
    _selectedLeadType = raw == 'lead' ? 'Lead' : 'General Enquiry';
  }

  Future<void> _updateLeads(
    String updateID,
    String status,
    String remarks,
    String name,
  ) async {
    try {
      _isUpdating.value = true;

      final responseData = await AppInjector.whatsappLeadsRepo.updateLeadStatus(
        leadId: updateID,
        status: _mapStatus(status),
        leadType: _mapLeadType(_selectedLeadType),
        remark: remarks,
        name: name,
      );

      if (!mounted) return;

      if (responseData['success'].toString() == 'true') {
        await widget.onRefresh?.call();

        if (!mounted) return;

        Navigator.pop(context);

        AppSnackbar.show(
          context,
          message: responseData['message'] ?? 'Lead updated successfully',
          type: SnackbarType.success,
        );
      } else {
        AppSnackbar.show(
          context,
          message: responseData['message'] ?? 'Failed to update lead',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint("Update Lead Error: $e");

      if (!mounted) return;

      AppSnackbar.show(
        context,
        message: 'Something went wrong',
        type: SnackbarType.error,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    //   final phone = _fmtPhone(widget.lead.phoneNumber ?? '');
    final phone = '+91 ${widget.lead.phoneNumber}';

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: c.borderStrong),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.bottomSheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 16),
            child: Row(
              children: [
                _LargeAvatar(name: widget.lead.name ?? '?'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lead.name ?? 'Unknown',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: c.textSecondary,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: c.surfaceHigh,
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: c.border),

          // ── Scrollable body ──
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoGrid(lead: widget.lead),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: c.border),
                  const SizedBox(height: 20),

                  Text(
                    'EDIT DETAILS',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Name'),
                  const SizedBox(height: 6),
                  _InputField(controller: _nameCtrl, hint: 'Enter name'),
                  const SizedBox(height: 18),

                  _FieldLabel('Lead Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _leadTypes
                        .map(
                          (t) => _SelectChip(
                            label: t,
                            isSelected: _selectedLeadType == t,
                            onTap: () => setState(() => _selectedLeadType = t),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses
                        .map(
                          (s) => _SelectChip(
                            label: s,
                            isSelected: _selectedStatus == s,
                            onTap: () => setState(() => _selectedStatus = s),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),

                  _FieldLabel('Remark'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _remarkCtrl,
                    hint: 'Add notes or follow-up remarks...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: c.border),

          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: () {},
                    bgColor: Colors.transparent,
                    borderColor: c.borderStrong,
                    textColor: c.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isUpdating,
                    builder: (context, value, child) {
                      return AppButton(
                        text: value ? 'Saving...' : 'Save & Update',

                        loading: value,

                        onPressed: value
                            ? null
                            : () {
                                _updateLeads(
                                  widget.lead.sId!,
                                  _selectedStatus,
                                  _remarkCtrl.text.trim(),
                                  _nameCtrl.text.trim(),
                                );
                              },

                        bgColor: c.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  final String name;
  const _LargeAvatar({required this.name});

  String get _initials => AppHelperMethods.initialsNameCharacter(
    // _sanitize(name),
    name,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Read-only info grid ──────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final WhatsappLeadsDataModel lead;
  const _InfoGrid({required this.lead});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final raw = (lead.leadType ?? '').replaceAll('+', ' ').toLowerCase();
    final displayType = raw == 'lead'
        ? 'Lead'
        : raw.isNotEmpty
        ? 'General Enquiry'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(label: 'LEAD TYPE', value: displayType),
                ),
                VerticalDivider(width: 1, color: c.border),
                Expanded(
                  child: _InfoCell(
                    label: 'BRAND NUMBER',
                    value: lead.brandNumber ?? '—',
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoCell(
                    label: 'ENQUIRY DATE',
                    value: (lead.enquiryDate ?? '').isNotEmpty
                        ? lead.enquiryDate!
                        : '—',
                  ),
                ),
                VerticalDivider(width: 1, color: c.border),
                Expanded(
                  child: _InfoCell(
                    label: 'CREATED AT',
                    value: lead.createDate != null
                        ? '${lead.createDate!.split(' ').take(2).join(' ')}'
                              '${lead.createTime != null ? ' • ${lead.createTime}' : ''}'
                        : '-',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }
}

// ─── Styled input ─────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: c.inputText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.inputHint, fontSize: 13.5),
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.inputBorderFocus, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Selectable chip ─────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primary : c.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : c.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
