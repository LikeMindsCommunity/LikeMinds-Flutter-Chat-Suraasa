import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_ss_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_ss_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_ss_fl/src/utils/imports.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';

part 'participants_event.dart';
part 'participants_state.dart';

class ParticipantsBloc extends Bloc<ParticipantsEvent, ParticipantsState> {
  static ParticipantsBloc? _instance;
  static ParticipantsBloc get instance => _instance ??= ParticipantsBloc._();
  ParticipantsBloc._() : super(const ParticipantsInitial()) {
    on<GetParticipants>((event, emit) async {
      if (event.getParticipantsRequest.page == 1) {
        emit(
          const ParticipantsLoading(),
        );
      } else {
        emit(
          const ParticipantsPaginationLoading(),
        );
      }
      try {
        final LMResponse<GetParticipantsResponse> response =
            await locator<LikeMindsService>().getParticipants(
          event.getParticipantsRequest,
        );
        if (response.success) {
          GetParticipantsResponse getParticipantsResponse = response.data!;
          if (getParticipantsResponse.success) {
            emit(
              ParticipantsLoaded(
                getParticipantsResponse: getParticipantsResponse,
              ),
            );
          } else {
            debugPrint(getParticipantsResponse.errorMessage);
            emit(
              ParticipantsError(
                getParticipantsResponse.errorMessage!,
              ),
            );
          }
        } else {
          debugPrint(response.errorMessage);
          emit(
            ParticipantsError(
              response.errorMessage!,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        emit(
          const ParticipantsError(
            'An error occurred',
          ),
        );
      }
    });
  }
}
