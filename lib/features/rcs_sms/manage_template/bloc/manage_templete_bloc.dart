import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'manage_templete_event.dart';
part 'manage_templete_state.dart';

class ManageTempleteBloc extends Bloc<ManageTempleteEvent, ManageTempleteState> {
  ManageTempleteBloc() : super(ManageTempleteInitial()) {
    on<ManageTempleteEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
