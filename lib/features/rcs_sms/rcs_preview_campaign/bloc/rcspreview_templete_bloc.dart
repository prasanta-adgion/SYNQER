import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/model/rcs_preview_model.dart';
import 'package:synqer_io/features/rcs_sms/rcs_preview_campaign/repository/rcs_preview_repo.dart';

part 'rcspreview_templete_event.dart';
part 'rcspreview_templete_state.dart';

class RcspreviewTempleteBloc
    extends Bloc<RcspreviewTempleteEvent, RcspreviewTempleteState> {
  final RcsPreviewRepo rcsPreviewRepo;

  RcspreviewTempleteBloc({required this.rcsPreviewRepo})
    : super(RcspreviewTempleteInitial()) {
    on<FetchRcspreviewTempleteEvent>(_onFetchRcspreviewTemplete);
  }

  Future<void> _onFetchRcspreviewTemplete(
    FetchRcspreviewTempleteEvent event,
    Emitter<RcspreviewTempleteState> emit,
  ) async {
    emit(RcspreviewTempleteLoading());

    try {
      final res = await rcsPreviewRepo.fetchRcsPreviewTemplete();

      if (res.success) {
        emit(RcspreviewTempleteLoaded(templetes: res.data ?? []));
      } else {
        emit(
          const RcspreviewTempleteError(
            message: 'Failed to load RCS preview templetes',
          ),
        );
      }
    } catch (e) {
      emit(RcspreviewTempleteError(message: e.toString()));
    }
  }
}
