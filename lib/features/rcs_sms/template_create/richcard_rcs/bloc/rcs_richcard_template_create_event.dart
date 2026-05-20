part of 'rcs_richcard_template_create_bloc.dart';

sealed class RcsRichcardTemplateCreateEvent extends Equatable {
  const RcsRichcardTemplateCreateEvent();

  @override
  List<Object?> get props => [];
}

final class CreateRichCardRcsTemplateSubmitted
    extends RcsRichcardTemplateCreateEvent {
  final String name;
  final String textMessageContent;
  final List<Map<String, dynamic>> suggestions;
  final Map<String, dynamic>? payload;

  const CreateRichCardRcsTemplateSubmitted({
    required this.name,
    required this.textMessageContent,
    required this.suggestions,
    this.payload,
  });

  @override
  List<Object?> get props => [name, textMessageContent, suggestions, payload];
}
