import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';

class InvitationUserModel extends InvitationUser {
  InvitationUserModel({
    required super.email,
    required super.position,
    required super.role,
  });

  Map<String, dynamic> toJson() {
    return {"email": email, "position": position, "role": role};
  }

  factory InvitationUserModel.fromJson(Map<String, dynamic> json) {
    return InvitationUserModel(
      email: json['email'],
      position: json['position'],
      role: json['role'],
    );
  }
}
