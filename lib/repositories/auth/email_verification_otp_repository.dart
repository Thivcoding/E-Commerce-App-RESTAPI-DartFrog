import 'package:mongo_dart/mongo_dart.dart';

import '../../models/auth/email_verification_otp.dart';

class EmailVerificationOtpRepository {
  final DbCollection collection;

  EmailVerificationOtpRepository(Db db)
    : collection = db.collection(
        'email_verification_otps',
      );

  Future<void> create(
    EmailVerificationOtp otp,
  ) async {
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

  Future<Map<String, dynamic>?> findValidOtp({
    required ObjectId userId,
    required String otpHash,
  }) async {
    final result = await collection.findOne(
      where
          .eq('userId', userId)
          .eq('otpHash', otpHash)
          .eq('usedAt', null)
          .gt(
            'expiresAt',
            DateTime.now(),
          ),
    );

    return result;
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
      where.eq(
        'userId',
        userId,
      ),
    );
  }

  Future<void> incrementAttempts(
    ObjectId id,
  ) async {
    await collection.updateOne(
      where.id(id),
      modify.inc(
        'attempts',
        1,
      ),
    );
  }

  Future<Map<String, dynamic>?> findActiveOtp({
    required ObjectId userId,
  }) async {
    return await collection.findOne(
      where
          .eq('userId', userId)
          .eq('usedAt', null)
          .gt(
            'expiresAt',
            DateTime.now(),
          ),
    );
  }
}
