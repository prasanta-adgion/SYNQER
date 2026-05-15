// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/app_images.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/features/rcs_sms/create_campaign/widgets/campaign_details.dart';
import 'package:synqer_io/features/rcs_sms/create_campaign/widgets/upload_numbers.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/rcs_preview_screen.dart';

class SendSmsScreen extends StatefulWidget {
  final CampaignDetailsData campaignDetails;
  final UploadNumbersData uploadNumbers;
  final PreviewCampaignData? previewCampaign;
  final bool isReadyToSend;
  final VoidCallback? onCampaignSent;

  const SendSmsScreen({
    super.key,
    required this.campaignDetails,
    required this.uploadNumbers,
    required this.previewCampaign,
    required this.isReadyToSend,
    this.onCampaignSent,
  });

  @override
  State<SendSmsScreen> createState() => _SendSmsScreenState();
}

class _SendSmsScreenState extends State<SendSmsScreen> {
  final ValueNotifier<bool> _isSending = ValueNotifier(false);
  final ValueNotifier<bool> _sendSuccess = ValueNotifier(false);

  @override
  void dispose() {
    _isSending.dispose();
    _sendSuccess.dispose();
    super.dispose();
  }

  bool get _canSend {
    return widget.isReadyToSend &&
        widget.campaignDetails.campaignName.trim().isNotEmpty &&
        widget.uploadNumbers.numbers.isNotEmpty &&
        widget.previewCampaign != null;
  }

  bool get _hasRequiredData {
    return widget.campaignDetails.campaignName.trim().isNotEmpty &&
        widget.uploadNumbers.numbers.isNotEmpty &&
        widget.previewCampaign != null;
  }

  Future<void> _sendCampaign() async {
    if (!_canSend || _isSending.value) return;

    _isSending.value = true;

    try {
      final response = await AppInjector.sendRcsmessageRepo.sendRcsMessage(
        phoneNumbers: widget.uploadNumbers.numbers,
        templateId: widget.previewCampaign!.template.id,
        campaignName: widget.campaignDetails.campaignName.trim(),
        expireTime: _expireTime(),
        countryCode: _countryCode(widget.campaignDetails.country),
        variables: widget.previewCampaign!.variableValues,
      );

      debugPrint(response.toString());

      if (!mounted) return;

      final success = response is Map
          ? response['success'] == true || response['status'] == true
          : true;
      final message = response is Map ? response['message']?.toString() : null;

      if (success) {
        _sendSuccess.value = true;
        widget.onCampaignSent?.call();
      }
      AppSnackbar.show(
        context,
        message: success
            ? message ?? 'Campaign sent successfully.'
            : message ?? 'Unable to send campaign.',
        type: success ? SnackbarType.success : SnackbarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint("Error in RCS SMS Send $e");
      AppSnackbar.show(
        context,
        message: 'Something wrong, RCS SMS send',
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) _isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final template = widget.previewCampaign?.template;
    final Map<String, String> variables =
        widget.previewCampaign?.variableValues ?? const <String, String>{};

    return ValueListenableBuilder<bool>(
      valueListenable: _sendSuccess,
      builder: (context, sendSuccess, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: sendSuccess
              ? _CampaignSuccessView(
                  campaignName: widget.campaignDetails.campaignName,
                  recipientCount: widget.uploadNumbers.numbers.length,
                  templateName: template?.name ?? 'Selected template',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: c.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review & Send Campaign',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Confirm campaign details before sending RCS messages.',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _SummarySection(
                      title: 'Campaign Details',
                      icon: Icons.edit_note_rounded,
                      rows: [
                        _SummaryRow(
                          'Campaign Name',
                          widget.campaignDetails.campaignName,
                        ),
                        _SummaryRow('Channel', widget.campaignDetails.channel),
                        _SummaryRow('Country', widget.campaignDetails.country),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummarySection(
                      title: 'Audience',
                      icon: Icons.group_outlined,
                      rows: [
                        _SummaryRow(
                          'Selection Mode',
                          _audienceModeLabel(widget.uploadNumbers),
                        ),
                        _SummaryRow(
                          'Total Numbers',
                          '${widget.uploadNumbers.numbers.length}',
                        ),
                        if (widget.uploadNumbers.groupName?.isNotEmpty == true)
                          _SummaryRow('Group', widget.uploadNumbers.groupName!),
                        _SummaryRow(
                          'Sample Numbers',
                          widget.uploadNumbers.numbers.isEmpty
                              ? 'No numbers selected'
                              : widget.uploadNumbers.numbers.take(5).join(', '),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummarySection(
                      title: 'Selected Template',
                      icon: template?.icon ?? Icons.view_agenda_outlined,
                      rows: [
                        _SummaryRow(
                          'Template Name',
                          template?.name ?? 'Not selected',
                        ),
                        _SummaryRow(
                          'Template Type',
                          template?.type ?? 'Not selected',
                        ),
                        if (variables.isNotEmpty)
                          _SummaryRow('Variables', _variablesLabel(variables)),
                      ],
                    ),
                    if (!_hasRequiredData || !widget.isReadyToSend) ...[
                      const SizedBox(height: 14),
                      _WarningBanner(message: _missingLabel()),
                    ],
                    const SizedBox(height: 18),

                    ValueListenableBuilder<bool>(
                      valueListenable: _isSending,
                      builder: (context, isSending, _) {
                        final buttonEnabled = _canSend && !isSending;

                        return AppButton(
                          text: isSending
                              ? 'Sending Campaign...'
                              : 'Send Campaign',
                          onPressed: buttonEnabled ? _sendCampaign : null,
                          bgColor: buttonEnabled ? c.primary : c.surfaceHigh,
                          textColor: buttonEnabled
                              ? c.onBrand
                              : c.textSecondary,
                          icon: Icons.send_rounded,
                          iconColor: buttonEnabled
                              ? c.onBrand
                              : c.textSecondary,
                          btnHeight: 48,
                          borderRadius: 8,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          loading: isSending,
                          loaderColor: c.onBrand,
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _missingLabel() {
    if (widget.campaignDetails.campaignName.trim().isEmpty) {
      return 'Add a campaign name before sending.';
    }
    if (widget.uploadNumbers.numbers.isEmpty) {
      return 'Add at least one recipient number before sending.';
    }
    if (widget.previewCampaign == null) {
      return 'Select an RCS template before sending.';
    }
    if (!widget.isReadyToSend) {
      return 'Click Ready before sending the campaign.';
    }
    return 'Complete all required steps before sending.';
  }

  String _audienceModeLabel(UploadNumbersData data) {
    return switch (data.mode) {
      UploadAudienceMode.manual => 'Manual numbers',
      UploadAudienceMode.bulk => 'Bulk upload',
      UploadAudienceMode.group => 'Contact group',
    };
  }

  String _variablesLabel(Map<String, String> variables) {
    return variables.entries
        .map((entry) {
          final value = entry.value.trim().isEmpty ? '--' : entry.value.trim();
          return '${entry.key}: $value';
        })
        .join(', ');
  }

  String _expireTime() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day 23:59:59';
  }

  String _countryCode(String country) {
    return switch (country.trim().toLowerCase()) {
      'india' => '91',
      _ => '91',
    };
  }
}

class _CampaignSuccessView extends StatelessWidget {
  final String campaignName;
  final int recipientCount;
  final String templateName;

  const _CampaignSuccessView({
    required this.campaignName,
    required this.recipientCount,
    required this.templateName,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 170,
            height: 170,
            child: Lottie.asset(
              AppImages.successLottie,
              repeat: false,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Campaign Sent Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your RCS campaign has been queued and will start reaching recipients shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: [
              _SuccessDetail(
                label: 'Campaign',
                value: campaignName.trim().isEmpty ? '--' : campaignName,
              ),
              _SuccessDetail(label: 'Template', value: templateName),
              _SuccessDetail(
                label: 'Recipients',
                value: '$recipientCount numbers',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SuccessDetail({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
            ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: c.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_SummaryRow> rows;

  const _SummarySection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: c.primary, size: 17),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((row) => _SummaryLine(row: row)),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final _SummaryRow row;

  const _SummaryLine({required this.row});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              row.label,
              style: TextStyle(color: c.textMuted, fontSize: 11.5),
            ),
          ),
          Expanded(
            child: Text(
              row.value.trim().isEmpty ? '--' : row.value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;

  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.dangerSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: c.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: c.error,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);
}
