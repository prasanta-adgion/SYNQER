part of 'rcspreview_templete_bloc.dart';

sealed class RcspreviewTempleteEvent extends Equatable {
  const RcspreviewTempleteEvent();

  @override
  List<Object?> get props => [];
}

final class FetchRcspreviewTempleteEvent extends RcspreviewTempleteEvent {
  const FetchRcspreviewTempleteEvent();
}
