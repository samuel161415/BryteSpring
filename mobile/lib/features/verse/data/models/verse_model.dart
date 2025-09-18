import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  VerseModel({
    required super.verseId,
    required super.name,
    required super.subdomain,
    required super.email,
    required super.organizationName,
    super.logo,
    super.color,
    super.colorName,
    required super.channels,
    required super.assets,
    required super.branding,
    required super.initialChannels,
    required super.isNeutralView,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      verseId: json['verse_id'],
      name: json['name'],
      subdomain: json['subdomain'],
      email: json['email'],
      organizationName: json['organization_name'],
      logo: json['logo'],
      color: json['color'],
      colorName: json['color_name'],
      channels: List<String>.from(json['channels']),
      assets: List<String>.from(json['assets']),
      branding: Map<String, dynamic>.from(json['branding']),
      initialChannels: List<String>.from(json['initial_channels']),
      isNeutralView: json['is_neutral_view'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse_id': verseId,
      'name': name,
      'subdomain': subdomain,
      'email': email,
      'organization_name': organizationName,
      // 'logo': logo,
      // 'color': color,
      // 'color_name': colorName,
      // 'channels': channels,
      // 'assets': assets,
      'branding': {
        "logo_url": logo,
        "primary_color": color,
        "color_name": colorName,
      },
      'initial_channels': channels,
      'is_neutral_view': isNeutralView,
    };
  }
}
