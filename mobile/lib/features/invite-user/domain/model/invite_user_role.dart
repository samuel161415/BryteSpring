class InviteUserRole {
  final String roleId;
  final String role;
  bool? isSelected = false;

  InviteUserRole({required this.role, required this.roleId, this.isSelected});
  InviteUserRole copyWith({bool? selected}) {
    return InviteUserRole(
      roleId: roleId,
      role: role,
      isSelected: selected ?? this.isSelected,
    );
  }
}
