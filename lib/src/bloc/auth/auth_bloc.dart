import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_ss_fl/likeminds_chat_ss_fl.dart';
import 'package:likeminds_chat_ss_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_ss_fl/src/service/preference_service.dart';
import 'package:likeminds_chat_ss_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ss_fl/src/utils/imports.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static AuthBloc? _instance;
  static AuthBloc get instance => _instance ??= AuthBloc._();
  AuthBloc._() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is InitAuthEvent) {
        emit(AuthLoading());
        LMChat.setupLMChat(
          apiKey: event.apiKey,
          lmCallBack: event.callback,
          navigatorKey: event.navigatorKey,
        );
        emit(AuthInitiated());
      } else if (event is LoginEvent) {
        emit(AuthLoading());
        final response = await locator<LikeMindsService>()
            .initiateUser((InitiateUserRequestBuilder()
                  ..userId(event.userId)
                  ..userName(event.username))
                .build());
        if (response.success) {
          final user = response.data!.initiateUser!.user;
          final memberRights =
              await locator<LikeMindsService>().getMemberState();
          await locator<LMPreferenceService>().storeUserData(user);
          await locator<LMPreferenceService>()
              .storeCommunityData(response.data!.initiateUser!.community);
          await locator<LMPreferenceService>()
              .storeMemberRights(memberRights.data!);
          LMNotificationHandler.instance.registerDevice(user.id);
          emit(AuthSuccess(user: response.data!.initiateUser!.user));
        } else {
          emit(AuthError(message: response.errorMessage!));
        }
      } else if (event is LogoutEvent) {}
    });
  }
}
