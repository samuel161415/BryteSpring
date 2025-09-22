import 'package:mobile/features/invite-user/domain/model/invite_user_role.dart';

abstract class InviteVerseRoleState {}

class InviteVerseRoleInitial extends InviteVerseRoleState {}

class InviteVerseRoleLoading extends InviteVerseRoleState {}

class InviteVerseRoleSuccess extends InviteVerseRoleState {
  final List<InviteUserRole> invitedVerseRole;
  InviteVerseRoleSuccess(this.invitedVerseRole);
}

class InviteVerseRoleFailure extends InviteVerseRoleState {
  final String error;
  InviteVerseRoleFailure(this.error);
}
