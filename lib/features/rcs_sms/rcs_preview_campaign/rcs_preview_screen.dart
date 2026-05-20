// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synqer_io/core/app_injector.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/bloc/rcspreview_templete_bloc.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/rcs_preview_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/widgets/phone_preview.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/widgets/rcs_template_selection_screen.dart';

class CampaignTemplateData {
  final String id;
  final String name;
  final String type;
  final String brand;
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;

  const CampaignTemplateData({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.icon,
  });

  String get label => '$name -- $type';

  factory CampaignTemplateData.fromTemplate(Data template) {
    final type = (template.type?.trim().isNotEmpty ?? false)
        ? template.type!.trim()
        : 'template';
    final name = (template.name?.trim().isNotEmpty ?? false)
        ? template.name!.trim()
        : 'Untitled Template';

    return CampaignTemplateData(
      id: template.sId ?? name,
      name: name,
      type: type,
      brand: 'RCS Business',
      title: name,
      message: 'Preview selected $type template before sending campaign.',
      buttonText: 'Preview',
      icon: _iconFor(type, name),
    );
  }

  static IconData _iconFor(String type, String name) {
    final value = '${type.toLowerCase()} ${name.toLowerCase()}';
    if (value.contains('video')) return Icons.play_arrow_rounded;
    if (value.contains('offer')) return Icons.local_offer_rounded;
    if (value.contains('event')) return Icons.event_available_rounded;
    if (value.contains('carousel')) return Icons.view_carousel_rounded;
    if (value.contains('card')) return Icons.web_stories_rounded;
    return Icons.message_rounded;
  }

  @override
  bool operator ==(Object other) {
    return other is CampaignTemplateData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PreviewCampaignData {
  final CampaignTemplateData template;
  final Map<String, String> variableValues;

  const PreviewCampaignData({
    required this.template,
    this.variableValues = const {},
  });
}

class PreviewCampaign extends StatefulWidget {
  final int recipientCount;
  final PreviewCampaignData? initialData;
  final ValueChanged<PreviewCampaignData>? onChanged;

  const PreviewCampaign({
    super.key,
    required this.recipientCount,
    this.initialData,
    this.onChanged,
  });

  @override
  State<PreviewCampaign> createState() => _PreviewCampaignState();
}

class _PreviewCampaignState extends State<PreviewCampaign> {
  late final ValueNotifier<CampaignTemplateData?> _selectedTemplate;
  late final ValueNotifier<List<String>> _templateVariables;
  late final ValueNotifier<Map<String, String>> _templateVariableValues;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = ValueNotifier(widget.initialData?.template);
    _templateVariables = ValueNotifier(const []);
    _templateVariableValues = ValueNotifier(const {});
  }

  @override
  void dispose() {
    _selectedTemplate.dispose();
    _templateVariables.dispose();
    _templateVariableValues.dispose();
    super.dispose();
  }

  void _selectTemplate(CampaignTemplateData? template) {
    if (template == null) return;
    _selectedTemplate.value = template;
    _templateVariables.value = const [];
    _templateVariableValues.value = const {};
    widget.onChanged?.call(PreviewCampaignData(template: template));
  }

  void _onTemplateLoaded(TemplateData template) {
    final selectedTemplate = _selectedTemplate.value;
    if (selectedTemplate == null) return;
    if (template.id != null && template.id != selectedTemplate.id) return;

    final variables = template.templateDetails?.variables ?? const [];
    if (_sameVariables(_templateVariables.value, variables)) return;
    _templateVariables.value = variables;
    _templateVariableValues.value = {
      for (final variable in variables)
        variable: _templateVariableValues.value[variable] ?? '',
    };
  }

  void _updateVariableValue(String variable, String value) {
    _templateVariableValues.value = {
      ..._templateVariableValues.value,
      variable: value,
    };

    final selectedTemplate = _selectedTemplate.value;
    if (selectedTemplate == null) return;
    widget.onChanged?.call(
      PreviewCampaignData(
        template: selectedTemplate,
        variableValues: _templateVariableValues.value,
      ),
    );
  }

  void _syncSelectedTemplate(List<CampaignTemplateData> templates) {
    if (templates.isEmpty) return;

    final currentTemplate = _selectedTemplate.value;
    final currentStillExists =
        currentTemplate != null &&
        templates.any((template) => template.id == currentTemplate.id);

    if (currentStillExists) return;

    final initialTemplate = widget.initialData?.template;
    final matchingInitialTemplate = initialTemplate == null
        ? <CampaignTemplateData>[]
        : templates
              .where((template) => template.id == initialTemplate.id)
              .toList();
    final selectedTemplate = matchingInitialTemplate.isNotEmpty
        ? matchingInitialTemplate.first
        : templates.first;

    _selectTemplate(selectedTemplate);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocProvider(
      create: (_) =>
          RcspreviewTempleteBloc(rcsPreviewRepo: AppInjector.rcsPreviewRepo)
            ..add(const FetchRcspreviewTempleteEvent()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: BlocConsumer<RcspreviewTempleteBloc, RcspreviewTempleteState>(
          listener: (context, state) {
            if (state is RcspreviewTempleteLoaded) {
              _syncSelectedTemplate(_mapTemplates(state.templetes));
            }
          },
          builder: (context, state) {
            if (state is RcspreviewTempleteLoading ||
                state is RcspreviewTempleteInitial) {
              return const _TemplateStatus(
                message: 'Loading templates...',
                isLoading: true,
              );
            }

            if (state is RcspreviewTempleteError) {
              debugPrint('state is RcspreviewTempleteError: ${state.message}');
              return _TemplateError(
                message: 'Something went wrong.',
                onRetry: () => context.read<RcspreviewTempleteBloc>().add(
                  const FetchRcspreviewTempleteEvent(),
                ),
              );
            }

            final templates = state is RcspreviewTempleteLoaded
                ? _mapTemplates(state.templetes)
                : <CampaignTemplateData>[];

            if (templates.isEmpty) {
              return const _TemplateStatus(message: 'No templates found.');
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 720;

                final controls = ValueListenableBuilder<CampaignTemplateData?>(
                  valueListenable: _selectedTemplate,
                  builder: (context, template, _) {
                    return ValueListenableBuilder<List<String>>(
                      valueListenable: _templateVariables,
                      builder: (context, variables, _) {
                        return ValueListenableBuilder<Map<String, String>>(
                          valueListenable: _templateVariableValues,
                          builder: (context, variableValues, _) {
                            return _TemplateControls(
                              templates: templates,
                              selectedTemplate: template,
                              recipientCount: widget.recipientCount,
                              variables: variables,
                              variableValues: variableValues,
                              onVariableChanged: _updateVariableValue,
                              onChanged: _selectTemplate,
                            );
                          },
                        );
                      },
                    );
                  },
                );

                final preview = ValueListenableBuilder<CampaignTemplateData?>(
                  valueListenable: _selectedTemplate,
                  builder: (context, template, _) {
                    return ValueListenableBuilder<Map<String, String>>(
                      valueListenable: _templateVariableValues,
                      builder: (context, variableValues, _) {
                        final selectedTemplate = template ?? templates.first;
                        return FetchedPhonePreview(
                          templateId: selectedTemplate.id,
                          templateName: selectedTemplate.name,
                          templateType: selectedTemplate.type,
                          icon: selectedTemplate.icon,
                          variableValues: variableValues,
                          onTemplateLoaded: _onTemplateLoaded,
                        );
                      },
                    );
                  },
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controls,
                      const SizedBox(height: 26),
                      Center(child: preview),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: controls),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PREVIEW',
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          preview,
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<CampaignTemplateData> _mapTemplates(List<Data> templates) {
    return templates.map(CampaignTemplateData.fromTemplate).toList();
  }

  bool _sameVariables(List<String> current, List<String> next) {
    if (current.length != next.length) return false;
    for (var i = 0; i < current.length; i++) {
      if (current[i] != next[i]) return false;
    }
    return true;
  }
}

class _TemplateStatus extends StatelessWidget {
  final String message;
  final bool isLoading;

  const _TemplateStatus({required this.message, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(color: c.primary, strokeWidth: 2),
          )
        else
          Icon(Icons.info_outline_rounded, color: c.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _TemplateError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TemplateError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Icon(Icons.error_outline_rounded, color: c.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message, style: TextStyle(color: c.error, fontSize: 13)),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _TemplateVariablesFields extends StatelessWidget {
  final List<String> variables;
  final Map<String, String> variableValues;
  final void Function(String variable, String value) onChanged;

  const _TemplateVariablesFields({
    required this.variables,
    required this.variableValues,
    required this.onChanged,
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
          Text(
            'TEMPLATE VARIABLES',
            style: TextStyle(
              color: c.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          ...variables.map((variable) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                key: ValueKey(variable),
                initialValue: variableValues[variable] ?? '',
                onChanged: (value) => onChanged(variable, value),
                decoration: InputDecoration(
                  labelText: 'Variable [$variable]',
                  hintText: 'Value for [$variable]',
                  filled: true,
                  fillColor: c.inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  labelStyle: TextStyle(color: c.textSecondary, fontSize: 12),
                  hintStyle: TextStyle(color: c.inputHint, fontSize: 12),
                  border: _variableBorder(c.inputBorder),
                  enabledBorder: _variableBorder(c.inputBorder),
                  focusedBorder: _variableBorder(c.primary),
                ),
                style: TextStyle(color: c.inputText, fontSize: 13),
              ),
            );
          }),
        ],
      ),
    );
  }

  OutlineInputBorder _variableBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}

class _TemplateControls extends StatelessWidget {
  final List<CampaignTemplateData> templates;
  final CampaignTemplateData? selectedTemplate;
  final int recipientCount;
  final List<String> variables;
  final Map<String, String> variableValues;
  final void Function(String variable, String value) onVariableChanged;
  final ValueChanged<CampaignTemplateData?> onChanged;

  const _TemplateControls({
    required this.templates,
    required this.selectedTemplate,
    required this.recipientCount,
    required this.variables,
    required this.variableValues,
    required this.onVariableChanged,
    required this.onChanged,
  });

  Future<void> _openTemplateSelection(BuildContext context) async {
    final selectedItem = await Navigator.push<RcsTemplateSelectionItem>(
      context,
      MaterialPageRoute(
        builder: (_) => RcsTemplateSelectionScreen(
          templates: templates
              .map(
                (template) => RcsTemplateSelectionItem(
                  id: template.id,
                  name: template.name,
                  type: template.type,
                  icon: template.icon,
                ),
              )
              .toList(),
          selectedTemplateId: selectedTemplate?.id,
        ),
      ),
    );

    if (selectedItem == null) return;

    final selectedTemplates = templates
        .where((template) => template.id == selectedItem.id)
        .toList();
    if (selectedTemplates.isEmpty) return;

    onChanged(selectedTemplates.first);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isTextTemplate =
        selectedTemplate?.type.toLowerCase().contains('text') == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Select ',
            children: [
              TextSpan(
                text: 'RCS template',
                style: TextStyle(color: c.primary),
              ),
              const TextSpan(text: ' to campaign'),
            ],
          ),
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Template',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _openTemplateSelection(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.inputBorder),
            ),
            child: Row(
              children: [
                Icon(
                  selectedTemplate?.icon ?? Icons.message_rounded,
                  color: c.inputIcon,
                  size: 17,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedTemplate?.label ?? 'Choose template',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedTemplate == null
                          ? c.inputHint
                          : c.inputText,
                      fontSize: 13,
                      fontWeight: selectedTemplate == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: c.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isTextTemplate && variables.isNotEmpty) ...[
          _TemplateVariablesFields(
            variables: variables,
            variableValues: variableValues,
            onChanged: onVariableChanged,
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Icon(Icons.check_rounded, color: c.green, size: 15),
            const SizedBox(width: 4),
            Text(
              'Template loaded',
              style: TextStyle(
                color: c.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.phone_android_rounded, color: c.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Numbers to send: $recipientCount',
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
