import 'package:equatable/equatable.dart';

// Verse Entity matching database schema
class VerseJoinEntity extends Equatable {
  final String id; // _id ObjectId
  final String name;
  final String subdomain;
  final Map<String, dynamic>? branding;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final String createdBy; // ObjectId reference to Users._id
  final bool isSetupComplete; // New field for setup completion status

  const VerseJoinEntity({
    required this.id,
    required this.name,
    required this.subdomain,
    this.branding,
    this.settings,
    required this.createdAt,
    required this.createdBy,
    required this.isSetupComplete,
  });

  factory VerseJoinEntity.fromJson(Map<String, dynamic> json) {
    return VerseJoinEntity(
      id: json['_id'] ?? json['id'], // Handle both _id and id
      name: json['name'],
      subdomain: json['subdomain'],
      branding: json['branding'] != null
          ? Map<String, dynamic>.from(json['branding'])
          : null,
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      createdBy: json['created_by'] ?? json['createdBy'],
      isSetupComplete: json['is_setup_complete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'subdomain': subdomain,
      'branding': branding,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'is_setup_complete': isSetupComplete,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    subdomain,
    branding,
    settings,
    createdAt,
    createdBy,
    isSetupComplete,
  ];
}
