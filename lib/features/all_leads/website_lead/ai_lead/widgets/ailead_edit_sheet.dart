import 'package:flutter/material.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/helper_methods.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/all_leads/website_lead/ai_lead/model/ai_leads_model.dart';

class AILeadEditBottomSheet extends StatefulWidget {
  final AiLeadsDataModel lead;
  final Future<void> Function()? onRefresh;

  const AILeadEditBottomSheet({
    super.key,
    required this.lead,
    required this.onRefresh,
  });

  static Future<void> show(
    BuildContext context,
    AiLeadsDataModel lead, {
    required Future<void> Function()? onRefresh,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SafeArea(
        child: AILeadEditBottomSheet(lead: lead, onRefresh: onRefresh),
      ),
    );
  }

  @override
  State<AILeadEditBottomSheet> createState() => _AILeadEditBottomSheetState();
}

class _AILeadEditBottomSheetState extends State<AILeadEditBottomSheet> {
  late TextEditingController _notesCtrl;

  late ValueNotifier<bool> _isContacted;
  final ValueNotifier<bool> _isUpdating = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _notesCtrl = TextEditingController(text: widget.lead.notes ?? '');

    _isContacted = ValueNotifier(
      widget.lead.isContacted == true ||
          widget.lead.isContacted.toString() == 'true',
    );
  }

  Future<void> _updateLead() async {
    try {
      _isUpdating.value = true;

      final response = await AppInjector.aiLeadRepository.updateAiWebLead(
        id: widget.lead.sId!,
        isContacted: _isContacted.value,
        notes: _notesCtrl.text.trim(),
      );

      if (!mounted) return;

      if (response['success'].toString() == 'true') {
        await widget.onRefresh?.call();

        if (!mounted) return;

        Navigator.pop(context);

        AppSnackbar.show(
          context,
          message: response['message'] ?? 'Lead updated successfully',
          type: SnackbarType.success,
        );
      } else {
        AppSnackbar.show(
          context,
          message: response['message'] ?? 'Failed to update lead',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint('Update Lead Error: $e');

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
    _notesCtrl.dispose();
    _isContacted.dispose();
    _isUpdating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Row(
              children: [
                _Avatar(name: widget.lead.name ?? '?'),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lead.name ?? 'Unknown',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        widget.lead.phone ?? '-',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: c.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contacted',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Mark if you have reached out',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _isContacted,
                    builder: (_, value, __) {
                      return Switch(
                        value: value,
                        onChanged: (v) {
                          _isContacted.value = v;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes',
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _notesCtrl,
              maxLines: 5,
              style: TextStyle(color: c.inputText, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add notes or follow-up details...',
                hintStyle: TextStyle(color: c.inputHint),
                filled: true,
                fillColor: c.inputFill,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    bgColor: Colors.transparent,
                    textColor: c.textSecondary,
                    borderColor: c.borderStrong,
                    borderWidth: 1,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isUpdating,
                    builder: (_, loading, __) {
                      return AppButton(
                        text: loading ? 'Saving...' : 'Save',
                        loading: loading,
                        onPressed: loading ? null : _updateLead,
                        bgColor: c.primary,
                        icon: Icons.save_outlined,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  String get _initials => AppHelperMethods.initialsNameCharacter(name);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF7C4DFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}
