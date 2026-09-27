import 'package:ecommerce_api/config/env.dart';
import 'package:ecommerce_api/constants/role_constants.dart';
import 'package:ecommerce_api/dto/request/login_request.dart';
import 'package:ecommerce_api/dto/request/register_request.dart';
import 'package:ecommerce_api/dto/response/user_response.dart';
import 'package:ecommerce_api/models/password_reset_session.dart';
import 'package:ecommerce_api/models/user.dart';
import 'package:ecommerce_api/models/email_verification_otp.dart';
import 'package:ecommerce_api/repositories/email_verification_otp_repository.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/email_service.dart';
import 'package:ecommerce_api/utils/otp_hash_util.dart';
import 'package:ecommerce_api/utils/otp_util.dart';
import 'package:ecommerce_api/utils/jwt_util.dart';
import 'package:ecommerce_api/utils/password_util.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:ecommerce_api/models/password_reset_otp.dart';
import 'package:ecommerce_api/repositories/password_reset_otp_repository.dart';
import 'package:ecommerce_api/utils/password_reset_token_util.dart';
import 'package:ecommerce_api/repositories/password_reset_session_repository.dart';
import 'package:ecommerce_api/utils/password_reset_token_util.dart';
import 'package:ecommerce_api/utils/token_hash_util.dart';


class AuthService {
  final UserRepository repository;
  final EmailVerificationOtpRepository otpRepository;
  final PasswordResetOtpRepository passwordResetOtpRepository;
  final PasswordResetSessionRepository passwordResetSessionRepository;
  final EmailService emailService;

  AuthService(
    this.repository,
    this.otpRepository,
    this.passwordResetOtpRepository,
    this.passwordResetSessionRepository,
    this.emailService,
  );
  // =========================================================
  // REGISTER
  // =========================================================

  Future<UserResponse> register(
    RegisterRequest request,
  ) async {
    final name = request.name.trim();
    final email = request.email.trim().toLowerCase();
    final password = request.password;

    if (name.isEmpty) {
      throw Exception('Name is required');
    }

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    if (password.length < 6) {
      throw Exception(
        'Password must be at least 6 characters',
      );
    }

    final existingUser = await repository.findByEmail(email);

    if (existingUser != null) {
      throw Exception('Email already exists');
    }

    final now = DateTime.now();

    final user = User(
      name: name,
      email: email,
      password: PasswordUtil.hash(password),
      role: RoleConstants.user,
      isActive: true,
      isEmailVerified: false,
      emailVerifiedAt: null,
      createdAt: now,
      updatedAt: now,
    );

    final createdUser = await repository.create(user);

    // Send 6-digit OTP
    await _sendVerificationOtp(createdUser);

    return UserResponse.fromUser(createdUser);
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Map<String, dynamic>> login(
    LoginRequest request,
  ) async {
    final email = request.email.trim().toLowerCase();
    final password = request.password;

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    final user = await repository.findByEmail(email);

    if (user == null) {
      throw Exception('Invalid email or password');
    }

    if (!user.isActive) {
      throw Exception('User account is inactive');
    }

    if (!user.isEmailVerified) {
      throw Exception(
        'Please verify your email before login',
      );
    }

    final passwordValid = PasswordUtil.verify(
      password,
      user.password,
    );

    if (!passwordValid) {
      throw Exception(
        'Invalid email or password',
      );
    }

    if (user.id == null) {
      throw Exception('User ID is missing');
    }

    final userId = user.id!.oid;

    final accessToken = JwtUtil.generateAccessToken(
      userId: userId,
      email: user.email,
      role: user.role,
    );

    final refreshToken = JwtUtil.generateRefreshToken(
      userId: userId,
    );

    return {
      'user': UserResponse.fromUser(user).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // =========================================================
  // GET ME
  // =========================================================

  Future<UserResponse> getMe(
    String userId,
  ) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }

    final user = await repository.findById(userId);

    if (user == null) {
      throw Exception('User not found');
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    return UserResponse.fromUser(user);
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  Future<void> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    if (currentPassword.isEmpty) {
      throw Exception(
        'Current password is required',
      );
    }

    if (newPassword.isEmpty) {
      throw Exception(
        'New password is required',
      );
    }

    if (newPassword.length < 6) {
      throw Exception(
        'New password must be at least 6 characters',
      );
    }

    final user = await repository.findById(userId);

    if (user == null) {
      throw Exception('User not found');
    }

    final valid = PasswordUtil.verify(
      currentPassword,
      user.password,
    );

    if (!valid) {
      throw Exception(
        'Current password is incorrect',
      );
    }

    final hashedPassword = PasswordUtil.hash(
      newPassword,
    );

    await repository.updateById(
      userId,
      {
        'password': hashedPassword,
      },
    );
  }

  // =========================================================
  // EMAIL VALIDATION
  // =========================================================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // =========================================================
  // SEND 6-DIGIT OTP
  // =========================================================

  Future<void> _sendVerificationOtp(
    User user,
  ) async {
    if (user.id == null) {
      throw Exception('User ID is missing');
    }

    if (user.isEmailVerified) {
      throw Exception(
        'Email is already verified',
      );
    }

    // Generate 6-digit OTP
    final otp = OtpUtil.generate6DigitOtp();

    // Hash OTP before saving
    final otpHash = OtpHashUtil.hash(otp);

    // Expiration time
    final expiresAt = DateTime.now().add(
      Duration(
        minutes: Env.emailVerificationExpiresMinutes,
      ),
    );

    // Remove previous OTP
    await otpRepository.deleteByUserId(
      user.id!,
    );

    // Save new OTP
    await otpRepository.create(
      EmailVerificationOtp(
        userId: user.id!,
        email: user.email,
        otpHash: otpHash,
        expiresAt: expiresAt,
        usedAt: null,
        attempts: 0,
        createdAt: DateTime.now(),
      ),
    );

    // Send OTP to email
    await emailService.sendVerificationOtp(
      toEmail: user.email,
      name: user.name,
      otp: otp,
    );
  }

  // =========================================================
  // VERIFY EMAIL WITH OTP
  // =========================================================

  Future<void> verifyEmail({
  required String email,
  required String otp,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedOtp = otp.trim();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Invalid email address');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw Exception('OTP must be 6 digits');
    }

    final user = await repository.findByEmail(normalizedEmail);

    if (user == null) {
      throw Exception('Invalid or expired OTP');
    }

    if (!user.isActive) {
      throw Exception('User account is inactive');
    }

    if (user.isEmailVerified) {
      throw Exception('Email is already verified');
    }

    if (user.id == null) {
      throw Exception('User ID is missing');
    }

    // -------------------------------------------------
    // Find active OTP
    // -------------------------------------------------

    final otpDocument = await otpRepository.findActiveOtp(
      userId: user.id!,
    );

    if (otpDocument == null) {
      throw Exception('Invalid or expired OTP');
    }

    final rawOtpId = otpDocument['_id'];

    if (rawOtpId is! ObjectId) {
      throw Exception('Invalid verification OTP');
    }

    // -------------------------------------------------
    // Check attempts
    // -------------------------------------------------

    final attempts = otpDocument['attempts'] as int? ?? 0;

    const maxAttempts = 5;

    if (attempts >= maxAttempts) {
      throw Exception(
        'Too many invalid attempts. Please request a new OTP.',
      );
    }

    // -------------------------------------------------
    // Hash submitted OTP
    // -------------------------------------------------

    final otpHash = OtpHashUtil.hash(normalizedOtp);

    final savedOtpHash = otpDocument['otpHash']?.toString();

    // -------------------------------------------------
    // Compare OTP
    // -------------------------------------------------

    if (savedOtpHash != otpHash) {
      await otpRepository.incrementAttempts(rawOtpId);

      final currentAttempt = attempts + 1;

      if (currentAttempt >= maxAttempts) {
        throw Exception(
          'Too many invalid attempts. Please request a new OTP.',
        );
      }

      throw Exception(
        'Invalid OTP. Attempt $currentAttempt of $maxAttempts.',
      );
    }

    // -------------------------------------------------
    // OTP correct
    // -------------------------------------------------

    await otpRepository.markUsed(rawOtpId);

    // -------------------------------------------------
    // Verify user email
    // -------------------------------------------------

    await repository.updateById(
      user.id!.oid,
      {
        'isEmailVerified': true,
        'emailVerifiedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      },
    );
  }

  // =========================================================
  // RESEND VERIFICATION OTP
  // =========================================================

  Future<void> resendVerification(
    String email,
  ) async {
    final normalizedEmail =
        email.trim().toLowerCase();

    if (normalizedEmail.isEmpty ||
        !_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    // Do not reveal whether account exists
    if (user == null ||
        user.isEmailVerified ||
        !user.isActive) {
      return;
    }

    // Generate and send a new OTP
    await _sendVerificationOtp(user);
  }

  Future<void> forgotPassword(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Invalid email address');
    }

    final user = await repository.findByEmail(normalizedEmail);

    // Do not reveal whether the email exists.
    if (user == null || !user.isActive) {
      return;
    }

    if (user.id == null) {
      return;
    }

    final otp = OtpUtil.generate6DigitOtp();

    final otpHash = OtpHashUtil.hash(otp);

    final expiresAt = DateTime.now().add(
      Duration(
        minutes: Env.emailVerificationExpiresMinutes,
      ),
    );

    await passwordResetOtpRepository.deleteByUserId(
      user.id!,
    );

    await passwordResetOtpRepository.create(
      PasswordResetOtp(
        userId: user.id!,
        email: user.email,
        otpHash: otpHash,
        expiresAt: expiresAt,
        usedAt: null,
        attempts: 0,
        createdAt: DateTime.now(),
      ),
    );

    await emailService.sendPasswordResetOtp(
      toEmail: user.email,
      name: user.name,
      otp: otp,
    );
  }


  Future<String> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedOtp = otp.trim();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Invalid email address');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw Exception('OTP must be 6 digits');
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null || user.id == null) {
      throw Exception('Invalid or expired OTP');
    }

    if (!user.isActive) {
      throw Exception('Invalid or expired OTP');
    }

    final otpDocument =
        await passwordResetOtpRepository.findActiveOtp(
      userId: user.id!,
    );

    if (otpDocument == null) {
      throw Exception('Invalid or expired OTP');
    }

    final rawOtpId = otpDocument['_id'];

    if (rawOtpId is! ObjectId) {
      throw Exception('Invalid reset OTP');
    }

    final attempts =
        otpDocument['attempts'] as int? ?? 0;

    const maxAttempts = 5;

    if (attempts >= maxAttempts) {
      throw Exception(
        'Too many invalid attempts. Please request a new OTP.',
      );
    }

    final otpHash = OtpHashUtil.hash(
      normalizedOtp,
    );

    final savedOtpHash =
        otpDocument['otpHash']?.toString();

    if (savedOtpHash != otpHash) {
      await passwordResetOtpRepository.incrementAttempts(
        rawOtpId,
      );

      final currentAttempt = attempts + 1;

      if (currentAttempt >= maxAttempts) {
        throw Exception(
          'Too many invalid attempts. Please request a new OTP.',
        );
      }

      throw Exception(
        'Invalid OTP. Attempt '
        '$currentAttempt of $maxAttempts.',
      );
    }

    // =====================================================
    // OTP IS CORRECT
    // =====================================================

    // 1. Generate raw reset token
    final resetToken =
        PasswordResetTokenUtil.generate();

    // 2. Hash reset token
    final tokenHash =
        TokenHashUtil.hash(resetToken);

    // 3. Expire old reset sessions
    await passwordResetSessionRepository.deleteByUserId(
      user.id!,
    );

    // 4. Create new reset session
    final expiresAt = DateTime.now().add(
      const Duration(minutes: 10),
    );

    await passwordResetSessionRepository.create(
      PasswordResetSession(
        userId: user.id!,
        email: user.email,
        tokenHash: tokenHash,
        expiresAt: expiresAt,
        usedAt: null,
        createdAt: DateTime.now(),
      ),
    );

    // 5. Mark OTP as used
    await passwordResetOtpRepository.markUsed(
      rawOtpId,
    );

    // 6. Return RAW token to client
    return resetToken;
  }

  Future<void> resetPassword({
  required String email,
  required String resetToken,
  required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedToken = resetToken.trim();

    // =====================================================
    // 1. Validate email
    // =====================================================

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Invalid email address');
    }

    // =====================================================
    // 2. Validate reset token
    // =====================================================

    if (normalizedToken.isEmpty) {
      throw Exception('Reset token is required');
    }

    // =====================================================
    // 3. Validate new password
    // =====================================================

    if (newPassword.isEmpty) {
      throw Exception('New password is required');
    }

    if (newPassword.length < 8) {
      throw Exception(
        'Password must be at least 8 characters',
      );
    }

    // =====================================================
    // 4. Find user
    // =====================================================

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null) {
      throw Exception('Invalid or expired reset token');
    }

    if (user.id == null) {
      throw Exception('User ID is missing');
    }

    if (!user.isActive) {
      throw Exception('User account is inactive');
    }

    // =====================================================
    // 5. Hash reset token
    // =====================================================

    final tokenHash = TokenHashUtil.hash(
      normalizedToken,
    );

    // =====================================================
    // 6. Find valid reset session
    // =====================================================

    final session =
        await passwordResetSessionRepository.findValidSession(
      userId: user.id!,
      tokenHash: tokenHash,
    );

    if (session == null) {
      throw Exception('Invalid or expired reset token');
    }

    // =====================================================
    // 7. Get session ID
    // =====================================================

    final rawSessionId = session['_id'];

    if (rawSessionId is! ObjectId) {
      throw Exception('Invalid reset session');
    }

    // =====================================================
    // 8. Hash new password
    // =====================================================

    final hashedPassword = PasswordUtil.hash(
      newPassword,
    );

    // =====================================================
    // 9. Update user password
    // =====================================================

    await repository.updateById(
      user.id!.oid,
      {
        'password': hashedPassword,
        'updatedAt': DateTime.now(),
      },
    );

    // =====================================================
    // 10. Mark reset session as used
    // =====================================================

    await passwordResetSessionRepository.markUsed(
      rawSessionId,
    );
  }

}

