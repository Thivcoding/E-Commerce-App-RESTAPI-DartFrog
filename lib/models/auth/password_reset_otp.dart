import 'package:mongo_dart/mongo_dart.dart';

class PasswordResetOtp {
  final ObjectId? id;
  final ObjectId userId;
  final String email;
  final String otpHash;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final int attempts;
  final DateTime createdAt;

  PasswordResetOtp({
    this.id,
    required this.userId,
    required this.email,
    required this.otpHash,
    required this.expiresAt,
    this.usedAt,
    required this.attempts,
    required this.createdAt,
  });
}