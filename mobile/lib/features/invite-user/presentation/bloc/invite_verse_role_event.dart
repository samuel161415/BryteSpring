import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';

abstract class InviteVerseRoleEvent {}

class GetInviteVerseRoleEvent extends InviteVerseRoleEvent {
  final String verseId;
  GetInviteVerseRoleEvent(this.verseId);
}

class ToggleRoleEvent extends InviteVerseRoleEvent {
  final String roleId;
  final bool isSelected;

  ToggleRoleEvent(this.roleId, this.isSelected);
}
