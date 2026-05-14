import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';

class CampaignDetailsData {
  final String campaignName;
  final String channel;
  final String country;

  const CampaignDetailsData({
    this.campaignName = '',
    this.channel = 'RCS',
    this.country = 'India',
  });

  CampaignDetailsData copyWith({
    String? campaignName,
    String? channel,
    String? country,
    String? campaignType,
  }) {
    return CampaignDetailsData(
      campaignName: campaignName ?? this.campaignName,
      channel: channel ?? this.channel,
      country: country ?? this.country,
    );
  }
}

class CampaignDetails extends StatefulWidget {
  final CampaignDetailsData initialData;
  final GlobalKey<FormState>? formKey;
  final ValueChanged<CampaignDetailsData>? onChanged;

  const CampaignDetails({
    super.key,
    this.initialData = const CampaignDetailsData(),
    this.formKey,
    this.onChanged,
  });

  @override
  State<CampaignDetails> createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  static const _countries = ['India'];

  late final TextEditingController _channelController;
  late final TextEditingController _countryController;
  late final TextEditingController _campaignNameController;

  late final ValueNotifier<CampaignDetailsData> _detailsNotifier;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _detailsNotifier = ValueNotifier(data);
    _channelController = TextEditingController(text: data.channel);
    _countryController = TextEditingController(text: data.country);
    _campaignNameController = TextEditingController(text: data.campaignName)
      ..addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _campaignNameController.removeListener(_onNameChanged);
    _channelController.dispose();
    _countryController.dispose();
    _campaignNameController.dispose();
    _detailsNotifier.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final name = _campaignNameController.text.trim();
    _updateDetails(_detailsNotifier.value.copyWith(campaignName: name));
  }

  String? _validateCampaignName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please give campaign name to continue.';
    }
    return null;
  }

  void _updateDetails(CampaignDetailsData data) {
    _detailsNotifier.value = data;
    widget.onChanged?.call(data);
  }

  Future<void> _pickCountry() async {
    final selected = await _showOptionSheet(
      title: 'Select Country',
      options: _countries,
      selected: _detailsNotifier.value.country,
    );
    if (selected == null) return;
    _countryController.text = selected;
    _updateDetails(_detailsNotifier.value.copyWith(country: selected));
  }

  Future<String?> _showOptionSheet({
    required String title,
    required List<String> options,
    required String selected,
  }) {
    final c = context.colors;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            decoration: BoxDecoration(
              color: c.bottomSheet,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...options.map((option) {
                  final isSelected = option == selected;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? c.primary : c.textSecondary,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, option),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Form(
      key: widget.formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
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
                        'Campaign Details',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Set the campaign basics before uploading recipients.',
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
            _FieldLabel(label: 'Campaign Name', required: true),
            CustomTextFormField(
              controller: _campaignNameController,
              hint_text: 'Enter campaign name',
              fieldIcon: Icons.campaign_outlined,
              validator: _validateCampaignName,
            ),
            const SizedBox(height: 14),
            _FieldLabel(label: 'Campaign Channel'),
            CustomTextFormField(
              controller: _channelController,
              readOnly: true,
              fieldIcon: Icons.forum_rounded,
            ),
            const SizedBox(height: 14),
            _FieldLabel(label: 'Select Country'),
            CustomTextFormField(
              controller: _countryController,
              readOnly: true,
              onTap: _pickCountry,
              fieldIcon: Icons.public_rounded,
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: c.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (required)
            Text(
              ' *',
              style: TextStyle(
                color: c.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
