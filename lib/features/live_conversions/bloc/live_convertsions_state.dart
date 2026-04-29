part of 'live_convertsions_bloc.dart';

sealed class LiveConvertsionsState extends Equatable {
  const LiveConvertsionsState();

  @override
  List<Object> get props => [];
}

final class LiveConvertsionsInitial extends LiveConvertsionsState {}

class LiveConvertsionsLoading extends LiveConvertsionsState {}

class LiveConvertsionsLoaded extends LiveConvertsionsState {
  final List<ConversionsChatData> conversions;

  const LiveConvertsionsLoaded({required this.conversions});

  @override
  List<Object> get props => [conversions];
}

class LiveConvertsionsError extends LiveConvertsionsState {
  final String message;

  const LiveConvertsionsError({required this.message});

  @override
  List<Object> get props => [message];
}
