part of 'create_text_rcs_template_bloc.dart';

sealed class CreateTextRcsTemplateEvent extends Equatable {
  const CreateTextRcsTemplateEvent();

  @override
  List<Object?> get props => [];
}

final class CreateTextRcsTemplateSubmitted
    extends CreateTextRcsTemplateEvent {
  final String name;
  final String textMessageContent;
  final List<Map<String, dynamic>> suggestions;
  final Map<String, dynamic>? payload;

  const CreateTextRcsTemplateSubmitted({
    required this.name,
    required this.textMessageContent,
    required this.suggestions,
    this.payload,
  });

  @override
  List<Object?> get props => [
    name,
    textMessageContent,
    suggestions,
    payload,
  ];
}
