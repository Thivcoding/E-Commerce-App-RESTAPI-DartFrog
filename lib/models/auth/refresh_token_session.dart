import 'package:mongo_dart/mongo_dart.dart';

class RefreshTokenSession {
  final ObjectId? id;
  final ObjectId userId;
  final String tokenHash;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  RefreshTokenSession({
    this.id,
    required this.userId,
    required this.tokenHash,
    required this.expiresAt,
    this.revokedAt,
    required this.createdAt,
  });
}
