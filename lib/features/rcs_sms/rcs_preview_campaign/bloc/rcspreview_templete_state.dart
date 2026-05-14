part of 'rcspreview_templete_bloc.dart';

sealed class RcspreviewTempleteState extends Equatable {
  const RcspreviewTempleteState();

  @override
  List<Object?> get props => [];
}

final class RcspreviewTempleteInitial extends RcspreviewTempleteState {}

final class RcspreviewTempleteLoading extends RcspreviewTempleteState {}

final class RcspreviewTempleteLoaded extends RcspreviewTempleteState {
  final List<Data> templetes;

  const RcspreviewTempleteLoaded({required this.templetes});

  @override
  List<Object?> get props => [templetes];
}

final class RcspreviewTempleteError extends RcspreviewTempleteState {
  final String message;

  const RcspreviewTempleteError({required this.message});

  @override
  List<Object?> get props => [message];
}
