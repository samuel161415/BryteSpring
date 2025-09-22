import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_event.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_state.dart';
import '../../domain/usecase/create_invitation_usecase.dart';

class UserInvitationBloc extends Bloc<InvitedUserEvent, InvitedUserState> {
  final CreateUser createUser;

  UserInvitationBloc(this.createUser) : super(InvitedUserInitial()) {
    on<CreateInvitedUserEvent>((event, emit) async {
      emit(InvitedUserLoading());
      final result = await createUser(event.InvitedUser);
      result.fold(
        (failure) => emit(InvitedUserFailure(failure.message)),
        (message) => emit(InvitedUserSuccess(message)),
      );
    });
  }
}
