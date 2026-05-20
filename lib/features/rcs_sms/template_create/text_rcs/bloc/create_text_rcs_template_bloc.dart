import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/rcs_sms/template_create/text_rcs/repository/textrcs_template_repo.dart';

part 'create_text_rcs_template_event.dart';
part 'create_text_rcs_template_state.dart';

class CreateTextRcsTemplateBloc
    extends Bloc<CreateTextRcsTemplateEvent, CreateTextRcsTemplateState> {
  final TextRcsTemplateRepo _repo;

  CreateTextRcsTemplateBloc({required TextRcsTemplateRepo repo})
    : _repo = repo,
      super(CreateTextRcsTemplateInitial()) {
    on<CreateTextRcsTemplateSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateTextRcsTemplateSubmitted event,
    Emitter<CreateTextRcsTemplateState> emit,
  ) async {
    emit(CreateTextRcsTemplateLoading());

    try {
      final response = await _repo.createTextRcsTemplate(
        name: event.name,
        textMessageContent: event.textMessageContent,
        suggestions: event.suggestions,
        payload: event.payload,
      );

      emit(
        CreateTextRcsTemplateSuccess(
          message: _responseMessage(response) ?? 'Text RCS template created.',
          response: response,
        ),
      );
    } catch (e) {
      emit(CreateTextRcsTemplateError(message: e.toString()));
    }
  }

  String? _responseMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      final message = response['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }

    return null;
  }
}
