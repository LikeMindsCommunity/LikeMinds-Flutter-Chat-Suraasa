import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_chat_ss_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_ss_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatroomBloc extends Bloc<ChatroomEvent, ChatroomState> {
  static ChatroomBloc? _instance;
  static ChatroomBloc get instance => _instance ??= ChatroomBloc._();
  ChatroomBloc._() : super(ChatroomInitial()) {
    on<ChatroomEvent>((event, emit) async {
      if (event is InitChatroomEvent) {
        emit(ChatroomLoading());
        LMResponse<GetChatroomResponse> getChatroomResponse =
            await locator<LikeMindsService>()
                .getChatroom(event.chatroomRequest);
        emit(ChatroomLoaded(
          getChatroomResponse: getChatroomResponse.data!,
        ));
      }
    });
  }
}
