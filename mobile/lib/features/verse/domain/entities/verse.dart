import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final String verseId;
  String name;
  String subdomain;
  final String email;
  String organizationName;
  String? logo; // Can be a URL or a path, string is fine for now
  String? color;
  String? colorName;
  List<String> channels;
  List<String> assets;
  final Map<String, dynamic> branding;
  final List<String> initialChannels;
  final bool isNeutralView;

  Verse({
    required this.verseId,
    required this.name,
    required this.subdomain,
    required this.email,
    required this.organizationName,
    required this.logo,
    required this.color,
    required this.colorName,
    required this.channels,
    required this.assets,
    required this.branding,
    required this.initialChannels,
    required this.isNeutralView,
  });

  // Create an empty Verse instance
  factory Verse.empty() => Verse(
    verseId: '',
    name: '',
    subdomain: '',
    email: '',
    organizationName: '',
    logo: '',
    color: '',
    colorName: '',
    channels: [],
    assets: [],
    branding: {}, // Empty map for now
    initialChannels: [],
    isNeutralView: false,
  );

  // Create a copy of Verse with updated values
  Verse copyWith({
    String? verseId,
    String? name,
    String? subdomain,
    String? email,
    String? organizationName,
    String? logo,
    String? color,
    String? colorName,
    List<String>? channels,
    List<String>? assets,
    Map<String, dynamic>? branding,
    List<String>? initialChannels,
    bool? isNeutralView,
  }) {
    return Verse(
      verseId: verseId ?? this.verseId,
      name: name ?? this.name,
      subdomain: subdomain ?? this.subdomain,
      email: email ?? this.email,
      organizationName: organizationName ?? this.organizationName,
      logo: logo ?? this.logo,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
      channels: channels ?? this.channels,
      assets: assets ?? this.assets,
      branding: branding ?? this.branding,
      initialChannels: initialChannels ?? this.initialChannels,
      isNeutralView: isNeutralView ?? this.isNeutralView,
    );
  }

  @override
  List<Object?> get props => [
    verseId,
    name,
    subdomain,
    email,
    organizationName,
    logo,
    color,
    colorName,
    channels,
    assets,
    branding,
    initialChannels,
    isNeutralView,
  ];
}
