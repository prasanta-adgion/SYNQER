import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'rcs_richcard_template_create_event.dart';
part 'rcs_richcard_template_create_state.dart';

class RcsRichcardTemplateCreateBloc extends Bloc<RcsRichcardTemplateCreateEvent, RcsRichcardTemplateCreateState> {
  RcsRichcardTemplateCreateBloc() : super(RcsRichcardTemplateCreateInitial()) {
    on<RcsRichcardTemplateCreateEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
