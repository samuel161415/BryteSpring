import 'package:equatable/equatable.dart';

// Branding sub-schema
class BrandingEntity extends Equatable {
  final String? logoUrl;
  final String primaryColor;
  final String colorName;

  const BrandingEntity({
    this.logoUrl,
    required this.primaryColor,
    required this.colorName,
  });

  factory BrandingEntity.fromJson(Map<String, dynamic> json) {
    return BrandingEntity(
      logoUrl: json['logo_url'] ?? "",
      primaryColor: json['primary_color'] ?? '#3B82F6',
      colorName: json['color_name'] ?? 'Primary Blue',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'color_name': colorName,
    };
  }

  @override
  List<Object?> get props => [logoUrl, primaryColor, colorName];
}

// Settings sub-schema
class SettingsEntity extends Equatable {
  final bool isPublic;
  final bool allowInvites;
  final int maxUsers;
  final int storageLimit;

  const SettingsEntity({
    required this.isPublic,
    required this.allowInvites,
    required this.maxUsers,
    required this.storageLimit,
  });

  factory SettingsEntity.fromJson(Map<String, dynamic> json) {
    return SettingsEntity(
      isPublic: json['is_public'] ?? false,
      allowInvites: json['allow_invites'] ?? true,
      maxUsers: json['max_users'] ?? 50,
      storageLimit: json['storage_limit'] ?? 10737418240, // 10GB in bytes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_public': isPublic,
      'allow_invites': allowInvites,
      'max_users': maxUsers,
      'storage_limit': storageLimit,
    };
  }

  @override
  List<Object?> get props => [isPublic, allowInvites, maxUsers, storageLimit];
}

// Verse Entity matching complete database schema
class VerseJoinEntity extends Equatable {
  final String id; // _id ObjectId
  final String name;
  final String adminEmail;
  final String? subdomain;
  final String? organizationName;
  final BrandingEntity branding;
  final SettingsEntity settings;
  final bool isSetupComplete;
  final DateTime? setupCompletedAt;
  final String? setupCompletedBy; // ObjectId reference to User
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // ObjectId reference to Users._id

  const VerseJoinEntity({
    required this.id,
    required this.name,
    required this.adminEmail,
    this.subdomain,
    this.organizationName,
    required this.branding,
    required this.settings,
    required this.isSetupComplete,
    this.setupCompletedAt,
    this.setupCompletedBy,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory VerseJoinEntity.fromJson(Map<String, dynamic> json) {
    return VerseJoinEntity(
      id: json['_id'] ?? json['id'], // Handle both _id and id
      name: json['name'],
      adminEmail: json['admin_email'],
      subdomain: json['subdomain'] ?? "subdomain",
      organizationName: json['organization_name'] ?? "Organization Name",
      branding: BrandingEntity.fromJson(json['branding'] ?? {}),
      settings: SettingsEntity.fromJson(json['settings'] ?? {}),
      isSetupComplete: json['is_setup_complete'] ?? false,
      setupCompletedAt: json['setup_completed_at'] != null
          ? DateTime.parse(json['setup_completed_at'])
          : null,
      setupCompletedBy: json['setup_completed_by'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['created_by']["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'admin_email': adminEmail,
      'subdomain': subdomain,
      'organization_name': organizationName,
      'branding': branding.toJson(),
      'settings': settings.toJson(),
      'is_setup_complete': isSetupComplete,
      'setup_completed_at': setupCompletedAt?.toIso8601String(),
      'setup_completed_by': setupCompletedBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    adminEmail,
    subdomain,
    organizationName,
    branding,
    settings,
    isSetupComplete,
    setupCompletedAt,
    setupCompletedBy,
    isActive,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
