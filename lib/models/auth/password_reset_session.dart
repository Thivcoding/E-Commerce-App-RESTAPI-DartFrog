import 'package:mongo_dart/mongo_dart.dart';

class PasswordResetSession {
  final ObjectId? id;
  final ObjectId userId;
  final String email;
  final String tokenHash;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;

  PasswordResetSession({
    this.id,
    required this.userId,
    required this.email,
    required this.tokenHash,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });
}