import 'dart:convert';

class User {
  final String id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final bool isActive;
  final DateTime lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> joinedVerse;
  final String token;
  final String refreshToken;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.isActive,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    required this.joinedVerse,
    required this.token,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      passwordHash: json['password_hash'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'],
      lastLogin: DateTime.parse(json['last_login']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      joinedVerse: List<String>.from(json['joined_verse']),
      token: json['token'], // Access token
      refreshToken: json['refresh_token'], // Refresh token
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'joined_verse': joinedVerse,
      'token': token,
      'refresh_token': refreshToken,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory User.fromJsonString(String jsonString) =>
      User.fromJson(json.decode(jsonString));
}
