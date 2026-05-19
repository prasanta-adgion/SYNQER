import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/widgets/phone_preview.dart';

class TextRcsCreateScreen extends StatefulWidget {
  const TextRcsCreateScreen({super.key});

  @override
  State<TextRcsCreateScreen> createState() => _TextRcsCreateScreenState();
}

class _TextRcsCreateScreenState extends State<TextRcsCreateScreen> {
  final nameController = TextEditingController();
  final msgController = TextEditingController();

  final _formNotifier = ValueNotifier<int>(0);
  final _variablesNotifier = ValueNotifier<List<String>>(['var1']);
  final _suggestionsNotifier = ValueNotifier<List<_TextRcsSuggestion>>([]);

  @override
  void initState() {
    super.initState();
    nameController.addListener(_notifyPreview);
    msgController.addListener(_notifyPreview);
    _variablesNotifier.addListener(_notifyPreview);
  }

  @override
  void dispose() {
    nameController.removeListener(_notifyPreview);
    msgController.removeListener(_notifyPreview);
    _variablesNotifier.removeListener(_notifyPreview);
    nameController.dispose();
    msgController.dispose();
    for (final suggestion in _suggestionsNotifier.value) {
      suggestion.dispose();
    }
    _formNotifier.dispose();
    _variablesNotifier.dispose();
    _suggestionsNotifier.dispose();
    super.dispose();
  }

  void _notifyPreview() {
    _formNotifier.value++;
  }

  void _addVariable() {
    final variables = List<String>.from(_variablesNotifier.value);
    final nextVariable = 'var${variables.length + 1}';
    variables.add(nextVariable);
    _variablesNotifier.value = variables;

    final insertion = '[${nextVariable}]';
    final selection = msgController.selection;
    final text = msgController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    msgController.text = text.replaceRange(start, end, insertion);
    msgController.selection = TextSelection.collapsed(
      offset: start + insertion.length,
    );
  }

  void _addSuggestion() {
    final suggestion = _TextRcsSuggestion();
    suggestion.addListener(_notifyPreview);
    _suggestionsNotifier.value = [
      ..._suggestionsNotifier.value,
      suggestion,
    ];
    _notifyPreview();
  }

  void _deleteSuggestion(_TextRcsSuggestion suggestion) {
    final suggestions = List<_TextRcsSuggestion>.from(
      _suggestionsNotifier.value,
    )..remove(suggestion);
    suggestion.removeListener(_notifyPreview);
    suggestion.dispose();
    _suggestionsNotifier.value = suggestions;
    _notifyPreview();
  }

  void _showCreateUnavailable() {
    AppSnackbar.show(
      context,
      message: 'Create text template API is not connected yet.',
      type: SnackbarType.info,
    );
  }

  TemplateData _previewTemplate() {
    final variables = _variablesNotifier.value;
    final suggestions = _suggestionsNotifier.value
        .where((suggestion) => suggestion.displayText.trim().isNotEmpty)
        .map(
          (suggestion) => SuggestionModel(
            suggestionType: suggestion.type,
            displayText: suggestion.displayText.trim(),
            postback: suggestion.postback.trim(),
            url: suggestion.type == 'URL' ? suggestion.url.trim() : null,
            phoneNumber: suggestion.type == 'Call'
                ? suggestion.phoneNumber.trim()
                : null,
          ),
        )
        .toList();

    return TemplateData(
      id: 'text-rcs-live-preview',
      name: nameController.text.trim().isEmpty
          ? 'Your Bot'
          : nameController.text.trim(),
      type: 'text',
      templateDetails: TemplateDetails(
        variables: variables,
        category: 'Text RCS',
      ),
      textMessageContent: msgController.text.trim().isEmpty
          ? 'Your message will appear here...'
          : msgController.text,
      suggestions: suggestions,
      status: 'draft',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: CustomAppBar(
        title: 'Create Text RCS Template',
        subtitle: 'Create engaging text-based RCS templates',
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 920;
            final form = _TemplateForm(
              nameController: nameController,
              msgController: msgController,
              suggestionsNotifier: _suggestionsNotifier,
              onAddVariable: _addVariable,
              onAddSuggestion: _addSuggestion,
              onDeleteSuggestion: _deleteSuggestion,
              onCreate: _showCreateUnavailable,
            );
            final preview = ValueListenableBuilder<int>(
              valueListenable: _formNotifier,
              builder: (context, _, __) {
                final template = _previewTemplate();
                return _LivePreview(template: template);
              },
            );

            if (isNarrow) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                children: [form, const SizedBox(height: 16), preview],
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: form),
                  const SizedBox(width: 18),
                  SizedBox(width: 320, child: preview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TemplateForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController msgController;
  final ValueNotifier<List<_TextRcsSuggestion>> suggestionsNotifier;
  final VoidCallback onAddVariable;
  final VoidCallback onAddSuggestion;
  final ValueChanged<_TextRcsSuggestion> onDeleteSuggestion;
  final VoidCallback onCreate;

  const _TemplateForm({
    required this.nameController,
    required this.msgController,
    required this.suggestionsNotifier,
    required this.onAddVariable,
    required this.onAddSuggestion,
    required this.onDeleteSuggestion,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Template Details',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 18),
          _FieldLabel(label: 'Template Name *'),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: nameController,
            hint_text: 'e.g. order_confirmation',
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            suffixIcon: _CharacterCount(controller: nameController, max: 40),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const _FieldLabel(label: 'Message Content *'),
              const Spacer(),
              _SmallActionButton(
                icon: Icons.add_rounded,
                label: 'Add Variable [var1]',
                onTap: onAddVariable,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: msgController,
            hint_text: 'Hi [var1], your order [var2] has been confirmed...',
            maxLines: 5,
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
          ),
          const SizedBox(height: 22),
          const _FieldLabel(label: 'Suggestions'),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<_TextRcsSuggestion>>(
            valueListenable: suggestionsNotifier,
            builder: (context, suggestions, _) {
              if (suggestions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                children: List.generate(suggestions.length, (index) {
                  final suggestion = suggestions[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == suggestions.length - 1 ? 0 : 10,
                    ),
                    child: _SuggestionCard(
                      index: index,
                      suggestion: suggestion,
                      onDelete: () => onDeleteSuggestion(suggestion),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onAddSuggestion,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Add Suggestion'),
            style: TextButton.styleFrom(
              foregroundColor: c.primary,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Create Template'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: c.primary,
                foregroundColor: c.onBrand,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final int index;
  final _TextRcsSuggestion suggestion;
  final VoidCallback onDelete;

  const _SuggestionCard({
    required this.index,
    required this.suggestion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          final typeField = ValueListenableBuilder<String>(
            valueListenable: suggestion.typeNotifier,
            builder: (context, value, _) {
              return _SuggestionTypeField(
                value: value,
                onChanged: (next) {
                  if (next == null) return;
                  suggestion.typeNotifier.value = next;
                },
              );
            },
          );
          final displayField = _FieldBlock(
            label: 'Display Text *',
            child: CustomTextFormField(
              controller: suggestion.displayTextController,
              hint_text: 'e.g. Track Order',
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              suffixIcon: _CharacterCount(
                controller: suggestion.displayTextController,
                max: 20,
              ),
            ),
          );
          final postbackField = _FieldBlock(
            label: 'Postback *',
            child: CustomTextFormField(
              controller: suggestion.postbackController,
              hint_text: 'e.g. track_order',
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              suffixIcon: _CharacterCount(
                controller: suggestion.postbackController,
                max: 20,
              ),
            ),
          );
          final extraField = ValueListenableBuilder<String>(
            valueListenable: suggestion.typeNotifier,
            builder: (context, type, _) {
              if (type == 'URL') {
                return _FieldBlock(
                  label: 'URL *',
                  child: CustomTextFormField(
                    controller: suggestion.urlController,
                    hint_text: 'https://example.com/track-order',
                    keyboardType: TextInputType.url,
                  ),
                );
              }
              if (type == 'Call') {
                return _FieldBlock(
                  label: 'Phone Number *',
                  child: CustomTextFormField(
                    controller: suggestion.phoneNumberController,
                    hint_text: 'e.g. +919876543210',
                    keyboardType: TextInputType.phone,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Suggestion ${index + 1}',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: c.error,
                      size: 18,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isNarrow) ...[
                _FieldBlock(label: 'Type', child: typeField),
                const SizedBox(height: 12),
                displayField,
                const SizedBox(height: 12),
                postbackField,
                ValueListenableBuilder<String>(
                  valueListenable: suggestion.typeNotifier,
                  builder: (context, type, _) {
                    if (type == 'Reply') return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: extraField,
                    );
                  },
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FieldBlock(label: 'Type', child: typeField),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: displayField),
                  ],
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: suggestion.typeNotifier,
                  builder: (context, type, _) {
                    if (type == 'Reply') {
                      return FractionallySizedBox(
                        widthFactor: 0.5,
                        child: postbackField,
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: postbackField),
                        const SizedBox(width: 12),
                        Expanded(child: extraField),
                      ],
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TextRcsSuggestion {
  final typeNotifier = ValueNotifier<String>('Reply');
  final displayTextController = TextEditingController();
  final postbackController = TextEditingController();
  final urlController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final List<VoidCallback> _listeners = [];

  String get type => typeNotifier.value;
  String get displayText => displayTextController.text;
  String get postback => postbackController.text;
  String get url => urlController.text;
  String get phoneNumber => phoneNumberController.text;

  _TextRcsSuggestion() {
    typeNotifier.addListener(_notify);
    displayTextController.addListener(_notify);
    postbackController.addListener(_notify);
    urlController.addListener(_notify);
    phoneNumberController.addListener(_notify);
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  void dispose() {
    typeNotifier.removeListener(_notify);
    displayTextController.removeListener(_notify);
    postbackController.removeListener(_notify);
    urlController.removeListener(_notify);
    phoneNumberController.removeListener(_notify);
    typeNotifier.dispose();
    displayTextController.dispose();
    postbackController.dispose();
    urlController.dispose();
    phoneNumberController.dispose();
    _listeners.clear();
  }
}

class _LivePreview extends StatelessWidget {
  final TemplateData template;

  const _LivePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.phone_iphone_rounded, color: c.textMuted, size: 15),
            const SizedBox(width: 7),
            Text(
              'Live Preview',
              style: TextStyle(
                color: c.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PhonePreview(
          templateId: template.id ?? 'text-rcs-live-preview',
          templateName: template.name ?? 'Your Bot',
          templateType: 'text',
          icon: Icons.chat_bubble_rounded,
          initialTemplate: template,
        ),
        const SizedBox(height: 9),
        Text(
          'Updates as you type',
          style: TextStyle(color: c.textMuted, fontSize: 10.5),
        ),
      ],
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SuggestionTypeField extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _SuggestionTypeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DropdownButtonFormField<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'Reply', child: Text('Reply')),
        DropdownMenuItem(value: 'URL', child: Text('URL')),
        DropdownMenuItem(value: 'Call', child: Text('Call')),
      ],
      onChanged: onChanged,
      dropdownColor: c.surface,
      style: TextStyle(
        color: c.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: c.accentSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.primary.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: c.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: c.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCount extends StatelessWidget {
  final TextEditingController controller;
  final int max;

  const _CharacterCount({required this.controller, required this.max});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Text(
          '${controller.text.length}/$max',
          style: TextStyle(
            color: c.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: context.colors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
