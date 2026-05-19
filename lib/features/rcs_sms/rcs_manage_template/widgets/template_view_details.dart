import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';
import 'package:synqer_io/core/widgets/custom_appbar.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart'
    as preview_model;
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/widgets/phone_preview.dart';

class TemplateViewDetails extends StatelessWidget {
  final RcsTemplateDataModel templateData;

  const TemplateViewDetails({super.key, required this.templateData});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final previewTemplate = _toPreviewTemplate(templateData);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: CustomAppBar(
        title: templateData.name.isEmpty
            ? 'Template Details'
            : templateData.name,
        subtitle: _valueOrDash(templateData.type),
        backgroundColor: c.surface,
        titleColor: c.textPrimary,
        subtitleColor: c.textSecondary,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 820;
            final details = _TemplateDetailsPanel(template: templateData);
            final preview = _PreviewPanel(
              template: templateData,
              previewTemplate: previewTemplate,
            );

            if (isNarrow) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [preview, const SizedBox(height: 14), details],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: details),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: preview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final RcsTemplateDataModel template;
  final preview_model.TemplateData previewTemplate;

  const _PreviewPanel({required this.template, required this.previewTemplate});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return _Section(
      title: 'Phone Preview',
      trailing: _StatusPill(status: template.status, compact: true),
      backgroundColor: c.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: PhonePreview(
            templateId: template.id,
            templateName: template.name,
            templateType: template.type,
            icon: _templateIcon(template.type),
            initialTemplate: previewTemplate,
          ),
        ),
      ),
    );
  }
}

class _TemplateDetailsPanel extends StatelessWidget {
  final RcsTemplateDataModel template;

  const _TemplateDetailsPanel({required this.template});

  @override
  Widget build(BuildContext context) {
    final variables = template.templateDetails?.variables ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'Overview',
          child: Column(
            children: [
              _DetailRow(label: 'Template ID', value: template.id),
              _DetailRow(label: 'Name', value: template.name),
              _DetailRow(label: 'Type', value: template.type),
              _DetailRow(label: 'Status', value: template.status),
              _DetailRow(
                label: 'Category',
                value: template.templateDetails?.category ?? '',
              ),
              _DetailRow(label: 'Orientation', value: template.orientation),
              _DetailRow(label: 'Size', value: _templateSize(template)),
              _DetailRow(
                label: 'Created',
                value: _formatDate(template.createdAt),
              ),
              _DetailRow(
                label: 'Updated',
                value: _formatDate(template.updatedAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (variables.isNotEmpty) ...[
          _Section(
            title: 'Variables',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: variables.map((variable) {
                return _InfoChip(label: variable);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (template.textMessageContent.trim().isNotEmpty) ...[
          _Section(
            title: 'Text Message',
            child: _BodyText(template.textMessageContent),
          ),
          const SizedBox(height: 12),
        ],
        if (template.suggestions.isNotEmpty) ...[
          _SuggestionSection(
            title: 'Template Actions',
            suggestions: template.suggestions,
          ),
          const SizedBox(height: 12),
        ],
        if (template.standAlone != null) ...[
          _StandaloneSection(card: template.standAlone!),
          const SizedBox(height: 12),
        ],
        if (template.carouselList.isNotEmpty)
          _CarouselSection(cards: template.carouselList),
      ],
    );
  }
}

class _StandaloneSection extends StatelessWidget {
  final CarouselCard card;

  const _StandaloneSection({required this.card});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Standalone Card',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Title', value: card.cardTitle),
          _DetailRow(label: 'Description', value: card.cardDescription),
          _DetailRow(label: 'Media', value: card.fileName),
          if (card.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SuggestionList(suggestions: card.suggestions),
          ],
        ],
      ),
    );
  }
}

class _CarouselSection extends StatelessWidget {
  final List<CarouselCard> cards;

  const _CarouselSection({required this.cards});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Carousel Cards',
      child: Column(
        children: List.generate(cards.length, (index) {
          final card = cards[index];
          return _CardItem(
            title: 'Card ${index + 1}',
            children: [
              _DetailRow(label: 'Title', value: card.cardTitle),
              _DetailRow(label: 'Description', value: card.cardDescription),
              _DetailRow(label: 'Media', value: card.fileName),
              if (card.suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SuggestionList(suggestions: card.suggestions),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  final String title;
  final List<SuggestionModel> suggestions;

  const _SuggestionSection({required this.title, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      child: _SuggestionList(suggestions: suggestions),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<SuggestionModel> suggestions;

  const _SuggestionList({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(suggestions.length, (index) {
        final suggestion = suggestions[index];
        return _CardItem(
          title: suggestion.displayText.isEmpty
              ? 'Action ${index + 1}'
              : suggestion.displayText,
          children: [
            _DetailRow(label: 'Type', value: suggestion.suggestionType),
            _DetailRow(label: 'Postback', value: suggestion.postback),
            _DetailRow(label: 'URL', value: suggestion.url),
            _DetailRow(label: 'Phone', value: suggestion.phoneNumber),
          ],
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final Color? backgroundColor;

  const _Section({
    required this.title,
    required this.child,
    this.trailing,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                color: c.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              _valueOrDash(value),
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CardItem({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 4),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SelectableText(
      text,
      style: TextStyle(color: c.textPrimary, fontSize: 13, height: 1.45),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool compact;

  const _StatusPill({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final normalized = status.toLowerCase();

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (normalized) {
      case 'approved':
        bgColor = c.successSoft;
        textColor = c.green;
        icon = Icons.check_circle_outline;
      case 'rejected':
        bgColor = c.dangerSoft;
        textColor = c.error;
        icon = Icons.cancel_outlined;
      default:
        bgColor = c.warningSoft;
        textColor = c.warning;
        icon = Icons.access_time_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            _valueOrDash(status),
            style: TextStyle(
              color: textColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

preview_model.TemplateData _toPreviewTemplate(RcsTemplateDataModel template) {
  return preview_model.TemplateData(
    id: template.id,
    userId: template.userId,
    name: template.name,
    type: template.type,
    templateDetails: template.templateDetails == null
        ? null
        : preview_model.TemplateDetails(
            variables: template.templateDetails!.variables,
            category: template.templateDetails!.category,
          ),
    textMessageContent: template.textMessageContent,
    suggestions: template.suggestions.map(_toPreviewSuggestion).toList(),
    orientation: template.orientation,
    height: template.height,
    width: template.width,
    standAlone: template.standAlone == null
        ? null
        : preview_model.StandAloneCard(
            cardTitle: template.standAlone!.cardTitle,
            cardDescription: template.standAlone!.cardDescription,
            fileName: template.standAlone!.fileName,
            suggestions: template.standAlone!.suggestions
                .map(_toPreviewSuggestion)
                .toList(),
          ),
    carouselList: template.carouselList.map(_toPreviewCarouselCard).toList(),
    mediaUrls: template.mediaUrls,
    status: template.status,
    rmlResponse: template.rmlResponse,
    createdAt: template.createdAt,
    updatedAt: template.updatedAt,
    version: template.version,
  );
}

preview_model.CarouselCard _toPreviewCarouselCard(CarouselCard card) {
  return preview_model.CarouselCard(
    cardTitle: card.cardTitle,
    cardDescription: card.cardDescription,
    fileName: card.fileName,
    suggestions: card.suggestions.map(_toPreviewSuggestion).toList(),
  );
}

preview_model.SuggestionModel _toPreviewSuggestion(SuggestionModel suggestion) {
  return preview_model.SuggestionModel(
    suggestionType: suggestion.suggestionType,
    displayText: suggestion.displayText,
    postback: suggestion.postback,
    phoneNumber: suggestion.phoneNumber,
    url: suggestion.url,
  );
}

IconData _templateIcon(String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('carousel')) return Icons.view_carousel_outlined;
  if (normalized.contains('card')) return Icons.view_agenda_outlined;
  if (normalized.contains('text') || normalized.contains('sms')) {
    return Icons.sms_outlined;
  }
  return Icons.description_outlined;
}

String _templateSize(RcsTemplateDataModel template) {
  final height = template.height.trim();
  final width = template.width.trim();
  if (height.isEmpty && width.isEmpty) return '';
  if (height.isEmpty) return width;
  if (width.isEmpty) return height;
  return '$width x $height';
}

String _formatDate(String rawDate) {
  if (rawDate.trim().isEmpty) return '';
  try {
    final dt = DateTime.parse(rawDate).toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return rawDate;
  }
}

String _valueOrDash(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '--' : trimmed;
}
