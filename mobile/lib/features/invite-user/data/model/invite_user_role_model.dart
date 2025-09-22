import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/domain/model/invite_user_role.dart';

class InviteUserRoleModel extends InviteUserRole {
  InviteUserRoleModel({required super.role, required super.roleId});

  Map<String, dynamic> toJson() {
    return {"roleId": roleId, "role": role};
  }

  factory InviteUserRoleModel.fromJson(Map<String, dynamic> json) {
    return InviteUserRoleModel(roleId: json['_id'], role: json['name']);
  }
}
