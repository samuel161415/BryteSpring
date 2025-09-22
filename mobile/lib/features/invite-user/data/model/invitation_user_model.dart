import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';

class InvitationUserModel extends InvitationUser {
  InvitationUserModel({
    required super.email,
    required super.position,
    required super.verseId,

    required super.firstName,
    required super.lastName,
    required super.roleId,
    required super.subdomain,
  });

  Map<String, dynamic> toJson() {
    return {
      "verse_id": verseId,
      "email": email,
      "role_id": roleId,
      "first_name": firstName,
      "last_name": lastName,
      "position": position,
      "expires_in_days": 5,
      "subdomain": subdomain,
    };
  }

  factory InvitationUserModel.fromJson(Map<String, dynamic> json) {
    return InvitationUserModel(
      verseId: json['verse_id'],

      email: json['email'],
      position: json['position'],
      roleId: json['role_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      subdomain: json['subdomain'],
    );
  }
}
