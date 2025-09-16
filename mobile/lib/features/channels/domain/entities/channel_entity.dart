import 'package:equatable/equatable.dart';

class ChannelEntity extends Equatable {
  final String id;
  final String verseId;
  final String name;
  final String type; // 'channel' or 'folder'
  final String? description;
  final String? parentChannelId;
  final String path;
  final List<String> assetTypes;
  final ChannelVisibility visibility;
  final ChannelFolderSettings folderSettings;
  final String createdBy;
  final DateTime createdAt;
  final List<ChannelEntity> children;

  const ChannelEntity({
    required this.id,
    required this.verseId,
    required this.name,
    required this.type,
    this.description,
    this.parentChannelId,
    required this.path,
    required this.assetTypes,
    required this.visibility,
    required this.folderSettings,
    required this.createdBy,
    required this.createdAt,
    this.children = const [],
  });

  factory ChannelEntity.fromJson(Map<String, dynamic> json) {
    return ChannelEntity(
      id: json['_id'] ?? '',
      verseId: json['verse_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'folder',
      description: json['description'],
      parentChannelId: json['parent_channel_id'],
      path: json['path'] ?? '',
      assetTypes: List<String>.from(json['asset_types'] ?? []),
      visibility: ChannelVisibility.fromJson(json['visibility'] ?? {}),
      folderSettings: ChannelFolderSettings.fromJson(json['folder_settings'] ?? {}),
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => ChannelEntity.fromJson(child))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'verse_id': verseId,
      'name': name,
      'type': type,
      'description': description,
      'parent_channel_id': parentChannelId,
      'path': path,
      'asset_types': assetTypes,
      'visibility': visibility.toJson(),
      'folder_settings': folderSettings.toJson(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    verseId,
    name,
    type,
    description,
    parentChannelId,
    path,
    assetTypes,
    visibility,
    folderSettings,
    createdBy,
    createdAt,
    children,
  ];
}

class ChannelVisibility extends Equatable {
  final bool isPublic;
  final bool inheritedFromParent;

  const ChannelVisibility({
    required this.isPublic,
    required this.inheritedFromParent,
  });

  factory ChannelVisibility.fromJson(Map<String, dynamic> json) {
    return ChannelVisibility(
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

class ChannelFolderSettings extends Equatable {
  final bool allowSubfolders;
  final int maxDepth;

  const ChannelFolderSettings({
    required this.allowSubfolders,
    required this.maxDepth,
  });

  factory ChannelFolderSettings.fromJson(Map<String, dynamic> json) {
    return ChannelFolderSettings(
      allowSubfolders: json['allow_subfolders'] ?? true,
      maxDepth: json['max_depth'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allow_subfolders': allowSubfolders,
      'max_depth': maxDepth,
    };
  }

  @override
  List<Object?> get props => [allowSubfolders, maxDepth];
}

class ChannelStructureResponse extends Equatable {
  final String verseId;
  final List<ChannelEntity> structure;
  final ChannelStats stats;

  const ChannelStructureResponse({
    required this.verseId,
    required this.structure,
    required this.stats,
  });

  factory ChannelStructureResponse.fromJson(Map<String, dynamic> json) {
    return ChannelStructureResponse(
      verseId: json['verse_id'] ?? '',
      structure: (json['structure'] as List<dynamic>?)
          ?.map((channel) => ChannelEntity.fromJson(channel))
          .toList() ?? [],
      stats: ChannelStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse_id': verseId,
      'structure': structure.map((channel) => channel.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  @override
  List<Object?> get props => [verseId, structure, stats];
}

class ChannelStats extends Equatable {
  final int totalChannels;
  final int totalFolders;
  final int totalItems;

  const ChannelStats({
    required this.totalChannels,
    required this.totalFolders,
    required this.totalItems,
  });

  factory ChannelStats.fromJson(Map<String, dynamic> json) {
    return ChannelStats(
      totalChannels: json['total_channels'] ?? 0,
      totalFolders: json['total_folders'] ?? 0,
      totalItems: json['total_items'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_channels': totalChannels,
      'total_folders': totalFolders,
      'total_items': totalItems,
    };
  }

  @override
  List<Object?> get props => [totalChannels, totalFolders, totalItems];
}
