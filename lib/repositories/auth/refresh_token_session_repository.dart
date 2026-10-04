import 'package:mongo_dart/mongo_dart.dart';

import '../../models/auth/refresh_token_session.dart';

class RefreshTokenSessionRepository {
  final DbCollection collection;

  RefreshTokenSessionRepository(Db db)
    : collection = db.collection(
        'refresh_token_sessions',
      );

  Future<void> create(
    RefreshTokenSession session,
  ) async {
    await collection.insertOne({
      'userId': session.userId,
      'tokenHash': session.tokenHash,
      'expiresAt': session.expiresAt,
      'revokedAt': session.revokedAt,
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
          .eq('revokedAt', null)
          .gt(
            'expiresAt',
            DateTime.now(),
          ),
    );
  }

  Future<void> revokeSession(
    ObjectId id,
  ) async {
    await collection.updateOne(
      where.id(id),
      modify.set(
        'revokedAt',
        DateTime.now(),
      ),
    );
  }

  Future<void> revokeAllByUserId(
    ObjectId userId,
  ) async {
    await collection.updateMany(
      where.eq('userId', userId).eq('revokedAt', null),
      modify.set(
        'revokedAt',
        DateTime.now(),
      ),
    );
  }

  Future<void> deleteByUserId(
    ObjectId userId,
  ) async {
    await collection.deleteMany(
      where.eq(
        'userId',
        userId,
      ),
    );
  }
}
