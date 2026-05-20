import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';

class RcsSuggestionController {
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

  RcsSuggestionController() {
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

class SuggestionsSection extends StatelessWidget {
  final ValueNotifier<List<RcsSuggestionController>> suggestionsNotifier;
  final VoidCallback onAddSuggestion;
  final ValueChanged<RcsSuggestionController> onDeleteSuggestion;

  const SuggestionsSection({
    super.key,
    required this.suggestionsNotifier,
    required this.onAddSuggestion,
    required this.onDeleteSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Suggestions'),
        const SizedBox(height: 10),
        ValueListenableBuilder<List<RcsSuggestionController>>(
          valueListenable: suggestionsNotifier,
          builder: (context, suggestions, _) {
            if (suggestions.isEmpty) return const SizedBox.shrink();

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
        AppButton(
          text: 'Add Suggestion',
          onPressed: onAddSuggestion,
          bgColor: Colors.transparent,
          icon: Icons.add_rounded,
          textColor: c.primary,
          fontSize: 12,
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final int index;
  final RcsSuggestionController suggestion;
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
            label: 'Display TYPE Text *',
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
