import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synqer_io/features/live_chat/live_conversions/model/live_conversions_model.dart';

class LiveConversationReadState extends Equatable {
  final Map<String, String> readLastMessageByMobile;

  const LiveConversationReadState({
    this.readLastMessageByMobile = const {},
  });

  bool isLastMessageRead(ConversionsChatData chat) {
    final mobile = chat.customerMobile?.trim() ?? '';

    if (mobile.isEmpty) return false;

    return readLastMessageByMobile[mobile] == chat.lastMessageSignature;
  }

  @override
  List<Object?> get props => [readLastMessageByMobile];
}

class LiveConversationReadCubit extends Cubit<LiveConversationReadState> {
  LiveConversationReadCubit() : super(const LiveConversationReadState());

  void markLastMessageRead(ConversionsChatData chat) {
    final mobile = chat.customerMobile?.trim() ?? '';

    if (mobile.isEmpty) return;

    final currentSignature = state.readLastMessageByMobile[mobile];

    if (currentSignature == chat.lastMessageSignature) return;

    emit(
      LiveConversationReadState(
        readLastMessageByMobile: {
          ...state.readLastMessageByMobile,
          mobile: chat.lastMessageSignature,
        },
      ),
    );
  }
}
