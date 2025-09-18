import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final String message;
  final DashboardData data;

  const DashboardEntity({
    required this.message,
    required this.data,
  });

  factory DashboardEntity.fromJson(Map<String, dynamic> json) {
    return DashboardEntity(
      message: json['message'] ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [message, data];
}

class DashboardData extends Equatable {
  final DashboardUser user;
  final DashboardVerse verse;
  final DashboardRole role;
  final String timestamp;
  final AdminData? adminData;
  final CommonData commonData;

  const DashboardData({
    required this.user,
    required this.verse,
    required this.role,
    required this.timestamp,
    this.adminData,
    required this.commonData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: DashboardUser.fromJson(json['user'] ?? {}),
      verse: DashboardVerse.fromJson(json['verse'] ?? {}),
      role: DashboardRole.fromJson(json['role'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      adminData: json['adminData'] != null 
          ? AdminData.fromJson(json['adminData']) 
          : null,
      commonData: CommonData.fromJson(json['commonData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'verse': verse.toJson(),
      'role': role.toJson(),
      'timestamp': timestamp,
      'adminData': adminData?.toJson(),
      'commonData': commonData.toJson(),
    };
  }

  @override
  List<Object?> get props => [user, verse, role, timestamp, adminData, commonData];
}

class DashboardUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;

  const DashboardUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, avatarUrl];
}

class DashboardVerse extends Equatable {
  final String id;
  final String name;
  final String? subdomain;
  final String? organizationName;
  final DashboardBranding branding;
  final bool isSetupComplete;
  final DashboardUser? setupCompletedBy;

  const DashboardVerse({
    required this.id,
    required this.name,
    this.subdomain,
    this.organizationName,
    required this.branding,
    required this.isSetupComplete,
    this.setupCompletedBy,
  });

  factory DashboardVerse.fromJson(Map<String, dynamic> json) {
    return DashboardVerse(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subdomain: json['subdomain'],
      organizationName: json['organization_name'],
      branding: DashboardBranding.fromJson(json['branding'] ?? {}),
      isSetupComplete: json['is_setup_complete'] ?? false,
      setupCompletedBy: json['setup_completed_by'] != null
          ? DashboardUser.fromJson(json['setup_completed_by'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'subdomain': subdomain,
      'organization_name': organizationName,
      'branding': branding.toJson(),
      'is_setup_complete': isSetupComplete,
      'setup_completed_by': setupCompletedBy?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, subdomain, organizationName, branding, isSetupComplete, setupCompletedBy];
}

class DashboardBranding extends Equatable {
  final String? logoUrl;
  final String primaryColor;
  final String colorName;
  final String id;

  const DashboardBranding({
    this.logoUrl,
    required this.primaryColor,
    required this.colorName,
    required this.id,
  });

  factory DashboardBranding.fromJson(Map<String, dynamic> json) {
    return DashboardBranding(
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'] ?? '#3B82F6',
      colorName: json['color_name'] ?? 'Primary Blue',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'color_name': colorName,
      '_id': id,
    };
  }

  @override
  List<Object?> get props => [logoUrl, primaryColor, colorName, id];
}

class DashboardRole extends Equatable {
  final String id;
  final String name;
  final String description;
  final DashboardPermissions permissions;

  const DashboardRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory DashboardRole.fromJson(Map<String, dynamic> json) {
    return DashboardRole(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: DashboardPermissions.fromJson(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'permissions': permissions.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, permissions];
}

class DashboardPermissions extends Equatable {
  final bool manageUsers;
  final bool manageAssets;
  final bool manageChannels;
  final bool manageVerse;
  final bool inviteUsers;

  const DashboardPermissions({
    required this.manageUsers,
    required this.manageAssets,
    required this.manageChannels,
    required this.manageVerse,
    required this.inviteUsers,
  });

  factory DashboardPermissions.fromJson(Map<String, dynamic> json) {
    return DashboardPermissions(
      manageUsers: json['manage_users'] ?? false,
      manageAssets: json['manage_assets'] ?? false,
      manageChannels: json['manage_channels'] ?? false,
      manageVerse: json['manage_verse'] ?? false,
      inviteUsers: json['invite_users'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manage_users': manageUsers,
      'manage_assets': manageAssets,
      'manage_channels': manageChannels,
      'manage_verse': manageVerse,
      'invite_users': inviteUsers,
    };
  }

  @override
  List<Object?> get props => [manageUsers, manageAssets, manageChannels, manageVerse, inviteUsers];
}

class AdminData extends Equatable {
  final AdminInvitations invitations;
  final AdminStatistics statistics;
  final List<AdminActivity> recentActivity;
  final List<AdminAction> adminActions;

  const AdminData({
    required this.invitations,
    required this.statistics,
    required this.recentActivity,
    required this.adminActions,
  });

  factory AdminData.fromJson(Map<String, dynamic> json) {
    return AdminData(
      invitations: AdminInvitations.fromJson(json['invitations'] ?? {}),
      statistics: AdminStatistics.fromJson(json['statistics'] ?? {}),
      recentActivity: (json['recent_activity'] as List<dynamic>?)
          ?.map((activity) => AdminActivity.fromJson(activity))
          .toList() ?? [],
      adminActions: (json['admin_actions'] as List<dynamic>?)
          ?.map((action) => AdminAction.fromJson(action))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitations': invitations.toJson(),
      'statistics': statistics.toJson(),
      'recent_activity': recentActivity.map((activity) => activity.toJson()).toList(),
      'admin_actions': adminActions.map((action) => action.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [invitations, statistics, recentActivity, adminActions];
}

class AdminInvitations extends Equatable {
  final List<AdminInvitation> pending;
  final List<AdminInvitation> recent;

  const AdminInvitations({
    required this.pending,
    required this.recent,
  });

  factory AdminInvitations.fromJson(Map<String, dynamic> json) {
    return AdminInvitations(
      pending: (json['pending'] as List<dynamic>?)
          ?.map((invitation) => AdminInvitation.fromJson(invitation))
          .toList() ?? [],
      recent: (json['recent'] as List<dynamic>?)
          ?.map((invitation) => AdminInvitation.fromJson(invitation))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending.map((invitation) => invitation.toJson()).toList(),
      'recent': recent.map((invitation) => invitation.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [pending, recent];
}

class AdminInvitation extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String position;
  final DashboardRole role;
  final DashboardUser invitedBy;
  final String? createdAt;
  final String? acceptedAt;
  final String? expiresAt;
  final String status;

  const AdminInvitation({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.role,
    required this.invitedBy,
    this.createdAt,
    this.acceptedAt,
    this.expiresAt,
    required this.status,
  });

  factory AdminInvitation.fromJson(Map<String, dynamic> json) {
    return AdminInvitation(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      position: json['position'] ?? '',
      role: DashboardRole.fromJson(json['role'] ?? {}),
      invitedBy: DashboardUser.fromJson(json['invited_by'] ?? {}),
      createdAt: json['created_at'],
      acceptedAt: json['accepted_at'],
      expiresAt: json['expires_at'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'position': position,
      'role': role.toJson(),
      'invited_by': invitedBy.toJson(),
      'created_at': createdAt,
      'accepted_at': acceptedAt,
      'expires_at': expiresAt,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, position, role, invitedBy, createdAt, acceptedAt, expiresAt, status];
}

class AdminStatistics extends Equatable {
  final int totalMembers;
  final int totalChannels;
  final int pendingInvitations;

  const AdminStatistics({
    required this.totalMembers,
    required this.totalChannels,
    required this.pendingInvitations,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalMembers: json['total_members'] ?? 0,
      totalChannels: json['total_channels'] ?? 0,
      pendingInvitations: json['pending_invitations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_members': totalMembers,
      'total_channels': totalChannels,
      'pending_invitations': pendingInvitations,
    };
  }

  @override
  List<Object?> get props => [totalMembers, totalChannels, pendingInvitations];
}

class AdminActivity extends Equatable {
  final String id;
  final String action;
  final String resourceType;
  final DashboardUser user;
  final String timestamp;
  final Map<String, dynamic> details;

  const AdminActivity({
    required this.id,
    required this.action,
    required this.resourceType,
    required this.user,
    required this.timestamp,
    required this.details,
  });

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      id: json['_id'] ?? '',
      action: json['action'] ?? '',
      resourceType: json['resource_type'] ?? '',
      user: DashboardUser.fromJson(json['user'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'action': action,
      'resource_type': resourceType,
      'user': user.toJson(),
      'timestamp': timestamp,
      'details': details,
    };
  }

  @override
  List<Object?> get props => [id, action, resourceType, user, timestamp, details];
}

class AdminAction extends Equatable {
  final String name;
  final String description;
  final String endpoint;

  const AdminAction({
    required this.name,
    required this.description,
    required this.endpoint,
  });

  factory AdminAction.fromJson(Map<String, dynamic> json) {
    return AdminAction(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      endpoint: json['endpoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'endpoint': endpoint,
    };
  }

  @override
  List<Object?> get props => [name, description, endpoint];
}

class CommonData extends Equatable {
  final List<DashboardChannel> channels;
  final List<String> recentSearches;
  final List<AdminActivity> recentActivity;

  const CommonData({
    required this.channels,
    required this.recentSearches,
    required this.recentActivity,
  });

  factory CommonData.fromJson(Map<String, dynamic> json) {
    return CommonData(
      channels: (json['channels'] as List<dynamic>?)
          ?.map((channel) => DashboardChannel.fromJson(channel))
          .toList() ?? [],
      recentSearches: List<String>.from(json['recent_searches'] ?? []),
      recentActivity: (json['recent_activity'] as List<dynamic>?)
          ?.map((activity) => AdminActivity.fromJson(activity))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels.map((channel) => channel.toJson()).toList(),
      'recent_searches': recentSearches,
      'recent_activity': recentActivity.map((activity) => activity.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [channels, recentSearches, recentActivity];
}

class DashboardChannel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> assetTypes;
  final DashboardVisibility visibility;
  final String createdAt;

  const DashboardChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.assetTypes,
    required this.visibility,
    required this.createdAt,
  });

  factory DashboardChannel.fromJson(Map<String, dynamic> json) {
    return DashboardChannel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      assetTypes: List<String>.from(json['asset_types'] ?? []),
      visibility: DashboardVisibility.fromJson(json['visibility'] ?? {}),
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'asset_types': assetTypes,
      'visibility': visibility.toJson(),
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, name, description, assetTypes, visibility, createdAt];
}

class DashboardVisibility extends Equatable {
  final bool isPublic;
  final bool inheritedFromParent;

  const DashboardVisibility({
    required this.isPublic,
    required this.inheritedFromParent,
  });

  factory DashboardVisibility.fromJson(Map<String, dynamic> json) {
    return DashboardVisibility(
      isPublic: json['is_public'] ?? true,
      inheritedFromParent: json['inherited_from_parent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_public': isPublic,
      'inherited_from_parent': inheritedFromParent,
    };
  }

  @override
  List<Object?> get props => [isPublic, inheritedFromParent];
}
