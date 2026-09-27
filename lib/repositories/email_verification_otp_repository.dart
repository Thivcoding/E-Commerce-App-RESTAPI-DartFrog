import 'package:mongo_dart/mongo_dart.dart';

import '../models/email_verification_otp.dart';

class EmailVerificationOtpRepository {
  final DbCollection collection;

  EmailVerificationOtpRepository(Db db)
      : collection = db.collection('email_verification_otps');

  // =========================================================
  // CREATE OTP
  // =========================================================

  Future<void> create(EmailVerificationOtp otp) async {
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

  // =========================================================
  // FIND VALID OTP
  // =========================================================

  Future<Map<String, dynamic>?> findValidOtp({
    required ObjectId userId,
    required String otpHash,
  }) async {
    final result = await collection.findOne(
      where
          .eq('userId', userId)
          .eq('otpHash', otpHash)
          .eq('usedAt', null)
          .gt('expiresAt', DateTime.now()),
    );

    return result;
  }

  // =========================================================
  // MARK OTP AS USED
  // =========================================================

  Future<void> markUsed(ObjectId id) async {
    await collection.updateOne(
      where.id(id),
      modify
          .set('usedAt', DateTime.now()),
    );
  }

  // =========================================================
  // DELETE OLD OTPs FOR USER
  // =========================================================

  Future<void> deleteByUserId(ObjectId userId) async {
    await collection.deleteMany(
      where.eq('userId', userId),
    );
  }

  Future<void> incrementAttempts(ObjectId id) async {
    await collection.updateOne(
      where.id(id),
      modify.inc('attempts', 1),
    );
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
}