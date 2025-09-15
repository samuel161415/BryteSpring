import 'package:equatable/equatable.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

// Combined entity for reset password with verse and user info
class ResetPasswordContext extends Equatable {
  final VerseJoinEntity verse;
  final User user;

  const ResetPasswordContext({required this.verse, required this.user});

  factory ResetPasswordContext.fromJson(Map<String, dynamic> json) {
    return ResetPasswordContext(
      verse: VerseJoinEntity.fromJson(json['verse']),
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'verse': verse.toJson(), 'user': user.toJson()};
  }

  @override
  List<Object?> get props => [verse, user];
}
