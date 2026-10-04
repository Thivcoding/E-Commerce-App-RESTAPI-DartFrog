import 'package:mongo_dart/mongo_dart.dart';

import '../../models/auth/password_reset_otp.dart';

class PasswordResetOtpRepository {
  final DbCollection collection;

  PasswordResetOtpRepository(Db db)
    : collection = db.collection('password_reset_otps');

  Future<void> create(PasswordResetOtp otp) async {
    await collection.insertOne({
      'userId': otp.userId,
      'email': otp.email,
      'otpHash': otp.otpHash,
      'expiresAt': otp.expiresAt,
      'usedAt': otp.usedAt,
      'attempts': otp.attempts,
      'createdAt': otp.createdAt,
    });
  }

  Future<Map<String, dynamic>?> findActiveOtp({
    required ObjectId userId,
  }) async {
    return await collection.findOne(
      where
          .eq('userId', userId)
          .eq('usedAt', null)
          .gt('expiresAt', DateTime.now()),
    );
  }

  Future<void> incrementAttempts(ObjectId id) async {
    await collection.updateOne(
      where.id(id),
      modify.inc('attempts', 1),
    );
  }

  Future<void> markUsed(ObjectId id) async {
    await collection.updateOne(
      where.id(id),
      modify.set('usedAt', DateTime.now()),
    );
  }

  Future<void> deleteByUserId(ObjectId userId) async {
    await collection.deleteMany(
      where.eq('userId', userId),
    );
  }
}
