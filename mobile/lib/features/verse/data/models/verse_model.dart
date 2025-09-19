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
      color: _formatHexColor(json['color']),
      colorName: json['color_name'],
      channels: List<String>.from(json['channels']),
      assets: List<String>.from(json['assets']),
      branding: Map<String, dynamic>.from(json['branding']),
      initialChannels: List<String>.from(json['initial_channels']),
      isNeutralView: json['is_neutral_view'],
    );
  }
  static String? _formatHexColor(String? colorInput) {
    if (colorInput == null || colorInput.isEmpty) {
      return null;
    }

    // Remove any whitespace
    String cleanColor = colorInput.trim();

    // If it's already a valid hex color with #, return as is
    if (_isValidHexColor(cleanColor)) {
      return cleanColor;
    }

    // If it doesn't start with #, try adding it
    if (!cleanColor.startsWith('#')) {
      String withHash = '#$cleanColor';
      if (_isValidHexColor(withHash)) {
        return withHash;
      }
    }

    // If it's still invalid, return null
    return null;
  }

  static bool _isValidHexColor(String color) {
    if (color.isEmpty) return false;

    // Must start with #
    if (!color.startsWith('#')) return false;

    // Remove # for validation
    String hex = color.substring(1);

    // Check if it's 3, 6, or 8 characters (RGB, RRGGBB, RRGGBBAA)
    if (hex.length != 3 && hex.length != 6 && hex.length != 8) {
      return false;
    }

    // Check if all characters are valid hex digits (0-9, A-F, a-f)
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex);
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
        "primary_color": _formatHexColor(color) ?? "#3B82F6",
        "color_name": colorName,
      },
      'initial_channels': channels.map((channel) {
        return {
          "name": channel,
          "type": 'channel',
          "description": "description",
        };
      }).toList(),

      'is_neutral_view': isNeutralView,
    };
  }
}
