abstract class InvitedUserState {}

class InvitedUserInitial extends InvitedUserState {}

class InvitedUserLoading extends InvitedUserState {}

class InvitedUserSuccess extends InvitedUserState {
  final String message;
  InvitedUserSuccess(this.message);
}

class InvitedUserFailure extends InvitedUserState {
  final String error;
  InvitedUserFailure(this.error);
}
