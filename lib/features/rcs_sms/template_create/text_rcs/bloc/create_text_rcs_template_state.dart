part of 'create_text_rcs_template_bloc.dart';

sealed class CreateTextRcsTemplateState extends Equatable {
  const CreateTextRcsTemplateState();

  @override
  List<Object?> get props => [];
}

final class CreateTextRcsTemplateInitial
    extends CreateTextRcsTemplateState {}

final class CreateTextRcsTemplateLoading
    extends CreateTextRcsTemplateState {}

final class CreateTextRcsTemplateSuccess
    extends CreateTextRcsTemplateState {
  final String message;
  final dynamic response;

  const CreateTextRcsTemplateSuccess({
    required this.message,
    this.response,
  });

  @override
  List<Object?> get props => [message, response];
}

final class CreateTextRcsTemplateError extends CreateTextRcsTemplateState {
  final String message;

  const CreateTextRcsTemplateError({required this.message});

  @override
  List<Object?> get props => [message];
}
