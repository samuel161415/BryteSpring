import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';

abstract class InvitedUserEvent {}

class CreateInvitedUserEvent extends InvitedUserEvent {
  final InvitationUser InvitedUser;
  CreateInvitedUserEvent(this.InvitedUser);
}
