import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/invite-user/domain/usecase/get_verse_role.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_event.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_state.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_verse_role_event.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_verse_role_state.dart';
import '../../domain/usecase/create_invitation_usecase.dart';

class InvitedVerseUserRoleBloc
    extends Bloc<InviteVerseRoleEvent, InviteVerseRoleState> {
  final GetVerseRole getVerseRole;

  InvitedVerseUserRoleBloc(this.getVerseRole)
    : super(InviteVerseRoleInitial()) {
    on<GetInviteVerseRoleEvent>(_onLoadRoles);
    on<ToggleRoleEvent>(_onToggleRole);
  }

  void _onLoadRoles(event, emit) async {
    emit(InviteVerseRoleLoading());
    final result = await getVerseRole(event.verseId);
    result.fold(
      (failure) => emit(InviteVerseRoleFailure(failure.message)),
      (message) => emit(InviteVerseRoleSuccess(message)),
    );
  }

  void _onToggleRole(
    ToggleRoleEvent event,
    Emitter<InviteVerseRoleState> emit,
  ) {
    if (state is InviteVerseRoleSuccess) {
      final currentState = state as InviteVerseRoleSuccess;
      final updatedRoles = currentState.invitedVerseRole.map((role) {
        if (role.roleId == event.roleId) {
          return role.copyWith(selected: event.isSelected);
        }
        return role;
      }).toList();

      emit(InviteVerseRoleSuccess(updatedRoles));
    }
  }
}
