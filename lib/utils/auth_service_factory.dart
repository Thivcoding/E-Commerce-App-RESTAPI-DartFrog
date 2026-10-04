import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/repositories/auth/email_verification_otp_repository.dart';
import 'package:ecommerce_api/repositories/auth/password_reset_otp_repository.dart';
import 'package:ecommerce_api/repositories/auth/password_reset_session_repository.dart';
import 'package:ecommerce_api/repositories/auth/refresh_token_session_repository.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/auth_service.dart';
import 'package:ecommerce_api/services/email_service.dart';
import 'package:ecommerce_api/services/google_auth_service.dart';

AuthService createAuthService() {
  final db = Database.db;

  final userRepository = UserRepository(db);

  final otpRepository = EmailVerificationOtpRepository(db);

  final passwordResetOtpRepository = PasswordResetOtpRepository(db);

  final passwordResetSessionRepository = PasswordResetSessionRepository(db);

  final refreshTokenSessionRepository = RefreshTokenSessionRepository(db);

  final emailService = EmailService();

  final googleAuthService = GoogleAuthService();

  return AuthService(
    userRepository,
    otpRepository,
    passwordResetOtpRepository,
    passwordResetSessionRepository,
    refreshTokenSessionRepository,
    emailService,
    googleAuthService,
  );
}
