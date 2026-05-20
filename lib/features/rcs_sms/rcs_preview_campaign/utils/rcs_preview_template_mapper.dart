import 'package:flutter/material.dart';
import 'package:synqer_io/features/rcs_sms/rcs_manage_template/model/manage_template_model.dart'
    as manage_model;
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/templete_details_model.dart'
    as preview_model;

class RcsPreviewSuggestionInput {
  final String suggestionType;
  final String displayText;
  final String postback;
  final String? url;
  final String? phoneNumber;

  const RcsPreviewSuggestionInput({
    required this.suggestionType,
    required this.displayText,
    required this.postback,
    this.url,
    this.phoneNumber,
  });
}

preview_model.TemplateData mapManageTemplateToPreviewTemplate(
  manage_model.RcsTemplateDataModel template,
) {
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
    suggestions: template.suggestions.map(_mapManageSuggestion).toList(),
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
                .map(_mapManageSuggestion)
                .toList(),
          ),
    carouselList: template.carouselList.map(_mapManageCarouselCard).toList(),
    mediaUrls: template.mediaUrls,
    status: template.status,
    rmlResponse: template.rmlResponse,
    createdAt: template.createdAt,
    updatedAt: template.updatedAt,
    version: template.version,
  );
}

preview_model.TemplateData buildTextRcsPreviewTemplate({
  required String name,
  required String message,
  required List<String> variables,
  required List<RcsPreviewSuggestionInput> suggestions,
}) {
  final trimmedName = name.trim();
  final trimmedMessage = message.trim();

  return preview_model.TemplateData(
    id: 'text-rcs-live-preview',
    name: trimmedName.isEmpty ? 'Your Bot' : trimmedName,
    type: 'text',
    templateDetails: preview_model.TemplateDetails(
      variables: variables,
      category: 'Text RCS',
    ),
    textMessageContent: trimmedMessage.isEmpty
        ? 'Your message will appear here...'
        : message,
    suggestions: suggestions
        .where((suggestion) => suggestion.displayText.trim().isNotEmpty)
        .map(
          (suggestion) => preview_model.SuggestionModel(
            suggestionType: normalizeRcsSuggestionType(
              suggestion.suggestionType,
            ),
            displayText: suggestion.displayText.trim(),
            postback: suggestion.postback.trim(),
            url: _cleanOptional(suggestion.url),
            phoneNumber: _cleanOptional(suggestion.phoneNumber),
          ),
        )
        .toList(),
    status: 'draft',
  );
}

IconData rcsTemplateIcon(String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('carousel')) return Icons.view_carousel_outlined;
  if (normalized.contains('card')) return Icons.view_agenda_outlined;
  if (normalized.contains('text') || normalized.contains('sms')) {
    return Icons.sms_outlined;
  }
  return Icons.description_outlined;
}

String normalizeRcsSuggestionType(String? suggestionType) {
  final normalized = (suggestionType ?? '').trim().toLowerCase();

  switch (normalized) {
    case 'reply':
      return 'reply';
    case 'url':
    case 'url_action':
      return 'url_action';
    case 'call':
    case 'phone':
    case 'dialer_action':
      return 'dialer_action';
    default:
      return normalized;
  }
}

preview_model.CarouselCard _mapManageCarouselCard(
  manage_model.CarouselCard card,
) {
  return preview_model.CarouselCard(
    cardTitle: card.cardTitle,
    cardDescription: card.cardDescription,
    fileName: card.fileName,
    suggestions: card.suggestions.map(_mapManageSuggestion).toList(),
  );
}

preview_model.SuggestionModel _mapManageSuggestion(
  manage_model.SuggestionModel suggestion,
) {
  return preview_model.SuggestionModel(
    suggestionType: normalizeRcsSuggestionType(suggestion.suggestionType),
    displayText: suggestion.displayText,
    postback: suggestion.postback,
    phoneNumber: suggestion.phoneNumber,
    url: suggestion.url,
  );
}

String? _cleanOptional(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
