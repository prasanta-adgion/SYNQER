import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/utils/any_file_picker.dart';
import 'package:synqer_io/core/widgets/app_custom_button.dart';
import 'package:synqer_io/core/widgets/app_snackbar.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/core/widgets/custom_text_fields.dart';
import 'package:synqer_io/core/widgets/filepicker_bottomsheet.dart';
import 'package:synqer_io/features/live_chat/single_conversion/widgets/media_preview_screen.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/utils/rcs_preview_template_mapper.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/widgets/phone_preview.dart';
import 'package:synqer_io/features/rcs_sms/template_create/widgets/suggestions_section.dart';

class RichCardRcsCreateScreen extends StatefulWidget {
  const RichCardRcsCreateScreen({super.key});

  @override
  State<RichCardRcsCreateScreen> createState() =>
      _RichCardRcsCreateScreenState();
}

class _RichCardRcsCreateScreenState extends State<RichCardRcsCreateScreen> {
  static const int _maxVideoBytes = 10 * 1024 * 1024;

  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final _formNotifier = ValueNotifier<int>(0);
  final _variablesNotifier = ValueNotifier<List<String>>(['var1']);
  final _suggestionsNotifier = ValueNotifier<List<RcsSuggestionController>>([]);
  final _mediaNotifier = ValueNotifier<AppPickedFile?>(null);

  @override
  void initState() {
    super.initState();
    nameController.addListener(_notifyPreview);
    titleController.addListener(_notifyPreview);
    descriptionController.addListener(_notifyPreview);
    _variablesNotifier.addListener(_notifyPreview);
    _mediaNotifier.addListener(_notifyPreview);
  }

  @override
  void dispose() {
    nameController.removeListener(_notifyPreview);
    titleController.removeListener(_notifyPreview);
    descriptionController.removeListener(_notifyPreview);
    _variablesNotifier.removeListener(_notifyPreview);
    _mediaNotifier.removeListener(_notifyPreview);
    nameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    for (final suggestion in _suggestionsNotifier.value) {
      suggestion.dispose();
    }
    _formNotifier.dispose();
    _variablesNotifier.dispose();
    _suggestionsNotifier.dispose();
    _mediaNotifier.dispose();
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

    final insertion = '[$nextVariable]';
    final selection = descriptionController.selection;
    final text = descriptionController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    descriptionController.text = text.replaceRange(start, end, insertion);
    descriptionController.selection = TextSelection.collapsed(
      offset: start + insertion.length,
    );
  }

  void _addSuggestion() {
    final suggestion = RcsSuggestionController();
    suggestion.addListener(_notifyPreview);
    _suggestionsNotifier.value = [..._suggestionsNotifier.value, suggestion];
    _notifyPreview();
  }

  void _deleteSuggestion(RcsSuggestionController suggestion) {
    final suggestions = List<RcsSuggestionController>.from(
      _suggestionsNotifier.value,
    )..remove(suggestion);
    suggestion.removeListener(_notifyPreview);
    suggestion.dispose();
    _suggestionsNotifier.value = suggestions;
    _notifyPreview();
  }

  Future<void> _pickMedia() async {
    final file = await FilePickerBottomSheet.show(context);
    if (file == null) return;

    if (!_isAllowedMedia(file)) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Please upload an image, video or PDF.',
        type: SnackbarType.error,
      );
      return;
    }

    if (file.isVideo && (file.size ?? 0) > _maxVideoBytes) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Max video upload size is 10 MB.',
        type: SnackbarType.error,
      );
      return;
    }

    if (!mounted) return;

    AppPickedFile? previewedFile;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MediaPreviewScreen(
          file: file,
          onSend: (selectedFile, _) {
            previewedFile = selectedFile;
          },
          forChatScreen: false,
        ),
      ),
    );

    if (previewedFile == null) return;

    _mediaNotifier.value = previewedFile;
  }

  void _showCreateUnavailable() {
    AppSnackbar.show(
      context,
      message: 'Create rich card template API is not connected yet.',
      type: SnackbarType.error,
    );
  }

  TemplateData _previewTemplate() {
    final suggestions = _suggestionsNotifier.value
        .where((suggestion) => suggestion.displayText.trim().isNotEmpty)
        .map(
          (suggestion) => SuggestionModel(
            suggestionType: normalizeRcsSuggestionType(suggestion.type),
            displayText: suggestion.displayText.trim(),
            postback: suggestion.postback.trim(),
            url: suggestion.type == 'URL' ? suggestion.url.trim() : null,
            phoneNumber: suggestion.type == 'Call'
                ? suggestion.phoneNumber.trim()
                : null,
          ),
        )
        .toList();
    final media = _mediaNotifier.value;

    return TemplateData(
      id: 'rich-card-live-preview',
      name: nameController.text.trim().isEmpty
          ? 'Your Bot'
          : nameController.text.trim(),
      type: 'rich_card',
      standAlone: StandAloneCard(
        cardTitle: titleController.text.trim().isEmpty
            ? 'Card title'
            : titleController.text.trim(),
        cardDescription: descriptionController.text.trim().isEmpty
            ? 'Your card description goes here'
            : descriptionController.text,
        fileName: media?.path,
        suggestions: suggestions,
      ),
      mediaUrls: media?.path == null ? const [] : [media!.path!],
      status: 'draft',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: CustomAppBar(
        title: 'Create Rich Card RCS Template',
        subtitle: 'Create media-rich RCS templates',
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
            final form = _RichCardForm(
              nameController: nameController,
              titleController: titleController,
              descriptionController: descriptionController,
              mediaNotifier: _mediaNotifier,
              suggestionsNotifier: _suggestionsNotifier,
              onAddVariable: _addVariable,
              onPickMedia: _pickMedia,
              onAddSuggestion: _addSuggestion,
              onDeleteSuggestion: _deleteSuggestion,
              onCreate: _showCreateUnavailable,
            );
            final preview = ValueListenableBuilder<int>(
              valueListenable: _formNotifier,
              builder: (context, _, __) {
                return _LivePreview(template: _previewTemplate());
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

  bool _isAllowedMedia(AppPickedFile file) {
    final extension = file.extension?.toLowerCase();
    return file.isImage || file.isVideo || extension == 'pdf';
  }
}

class _RichCardForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final ValueNotifier<AppPickedFile?> mediaNotifier;
  final ValueNotifier<List<RcsSuggestionController>> suggestionsNotifier;
  final VoidCallback onAddVariable;
  final VoidCallback onPickMedia;
  final VoidCallback onAddSuggestion;
  final ValueChanged<RcsSuggestionController> onDeleteSuggestion;
  final VoidCallback onCreate;

  const _RichCardForm({
    required this.nameController,
    required this.titleController,
    required this.descriptionController,
    required this.mediaNotifier,
    required this.suggestionsNotifier,
    required this.onAddVariable,
    required this.onPickMedia,
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
            'Rich Card Template Details',
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
            hint_text: 'e.g. promo_card_01',
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            suffixIcon: _CharacterCount(controller: nameController, max: 40),
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: 'Card Title *'),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: titleController,
            hint_text: 'e.g. Summer Sale',
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            suffixIcon: _CharacterCount(controller: titleController, max: 50),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const _FieldLabel(label: 'Card Description'),
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
            controller: descriptionController,
            hint_text: 'Your card description goes here',
            maxLines: 4,
            inputFormatters: [LengthLimitingTextInputFormatter(2000)],
            suffixIcon: _CharacterCount(
              controller: descriptionController,
              max: 2000,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel(label: 'Media (Image / Video / PDF) *'),
          const SizedBox(height: 8),
          ValueListenableBuilder<AppPickedFile?>(
            valueListenable: mediaNotifier,
            builder: (context, file, _) {
              return _MediaUploadBox(file: file, onTap: onPickMedia);
            },
          ),
          const SizedBox(height: 10),

          Text(
            'Note: Max video upload size is 10 MB.',
            style: TextStyle(color: c.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 22),
          SuggestionsSection(
            suggestionsNotifier: suggestionsNotifier,
            onAddSuggestion: onAddSuggestion,
            onDeleteSuggestion: onDeleteSuggestion,
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: 'Create Template',
              onPressed: onCreate,
              bgColor: c.primary,
              icon: CupertinoIcons.create_solid,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaUploadBox extends StatelessWidget {
  final AppPickedFile? file;
  final VoidCallback onTap;

  const _MediaUploadBox({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasFile = file != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? c.primary.withValues(alpha: 0.45) : c.inputBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasFile ? Icons.insert_drive_file_outlined : Icons.upload_file,
                color: c.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasFile ? file!.name : 'Click to upload image, video or PDF',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasFile ? c.textPrimary : c.inputHint,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CreateLiveTemplatePhonePreview(
            template: template,
            title: template.name ?? 'Your Bot',
            icon: Icons.view_agenda_outlined,
          ),
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
