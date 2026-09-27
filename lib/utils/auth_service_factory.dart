import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/repositories/email_verification_otp_repository.dart';
import 'package:ecommerce_api/repositories/password_reset_otp_repository.dart';
import 'package:ecommerce_api/repositories/password_reset_session_repository.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/auth_service.dart';
import 'package:ecommerce_api/services/email_service.dart';

AuthService createAuthService() {
  final db = Database.db;

  final userRepository =
      UserRepository(db);

  final otpRepository =
      EmailVerificationOtpRepository(db);

  final passwordResetOtpRepository =
      PasswordResetOtpRepository(db);

  final passwordResetSessionRepository =
      PasswordResetSessionRepository(db);

  final emailService =
      EmailService();

  return AuthService(
    userRepository,
    otpRepository,
    passwordResetOtpRepository,
    passwordResetSessionRepository,
    emailService,
  );
}