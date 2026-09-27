import 'package:mongo_dart/mongo_dart.dart';

import '../models/password_reset_session.dart';

class PasswordResetSessionRepository {
  final DbCollection collection;

  PasswordResetSessionRepository(Db db)
      : collection = db.collection('password_reset_sessions');

  Future<void> create(
    PasswordResetSession session,
  ) async {
    await collection.insertOne({
      'userId': session.userId,
      'email': session.email,
      'tokenHash': session.tokenHash,
      'expiresAt': session.expiresAt,
      'usedAt': session.usedAt,
      'createdAt': session.createdAt,
    });
  }

  Future<Map<String, dynamic>?> findValidSession({
    required ObjectId userId,
    required String tokenHash,
  }) async {
    return await collection.findOne(
      where
          .eq('userId', userId)
          .eq('tokenHash', tokenHash)
          .eq('usedAt', null)
          .gt('expiresAt', DateTime.now()),
    );
  }

  Future<void> markUsed(
    ObjectId id,
  ) async {
    await collection.updateOne(
      where.id(id),
      modify.set(
        'usedAt',
        DateTime.now(),
      ),
    );
  }

  Future<void> deleteByUserId(
    ObjectId userId,
  ) async {
    await collection.deleteMany(
      where.eq('userId', userId),
    );
  }
}