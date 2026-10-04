import 'package:ecommerce_api/config/env.dart';
import 'package:ecommerce_api/constants/role_constants.dart';
import 'package:ecommerce_api/dto/request/auth/login_request.dart';
import 'package:ecommerce_api/dto/request/auth/register_request.dart';
import 'package:ecommerce_api/dto/response/users/user_response.dart';
import 'package:ecommerce_api/models/auth/email_verification_otp.dart';
import 'package:ecommerce_api/models/auth/password_reset_otp.dart';
import 'package:ecommerce_api/models/auth/password_reset_session.dart';
import 'package:ecommerce_api/models/auth/refresh_token_session.dart';
import 'package:ecommerce_api/models/users/user.dart';
import 'package:ecommerce_api/repositories/auth/email_verification_otp_repository.dart';
import 'package:ecommerce_api/repositories/auth/password_reset_otp_repository.dart';
import 'package:ecommerce_api/repositories/auth/password_reset_session_repository.dart';
import 'package:ecommerce_api/repositories/auth/refresh_token_session_repository.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/email_service.dart';
import 'package:ecommerce_api/services/google_auth_service.dart';
import 'package:ecommerce_api/utils/jwt_util.dart';
import 'package:ecommerce_api/utils/otp_hash_util.dart';
import 'package:ecommerce_api/utils/otp_util.dart';
import 'package:ecommerce_api/utils/password_reset_token_util.dart';
import 'package:ecommerce_api/utils/password_util.dart';
import 'package:ecommerce_api/utils/token_hash_util.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthService {
  final UserRepository repository;
  final EmailVerificationOtpRepository otpRepository;
  final PasswordResetOtpRepository passwordResetOtpRepository;
  final PasswordResetSessionRepository passwordResetSessionRepository;
  final RefreshTokenSessionRepository refreshTokenSessionRepository;
  final EmailService emailService;
  final GoogleAuthService googleAuthService;

  AuthService(
    this.repository,
    this.otpRepository,
    this.passwordResetOtpRepository,
    this.passwordResetSessionRepository,
    this.refreshTokenSessionRepository,
    this.emailService,
    this.googleAuthService,
  );

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
      provider: 'LOCAL',
      providerId: null,
      isActive: true,
      isEmailVerified: false,
      emailVerifiedAt: null,
      createdAt: now,
      updatedAt: now,
    );

    final createdUser = await repository.create(user);

    await _sendVerificationOtp(createdUser);

    return UserResponse.fromUser(createdUser);
  }

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

    if (user.password == null || user.password!.isEmpty) {
      if (user.provider.toUpperCase() == 'GOOGLE') {
        throw Exception(
          'This account uses Google login',
        );
      }

      throw Exception(
        'Password is not configured for this account',
      );
    }

    final passwordValid = PasswordUtil.verify(
      password,
      user.password!,
    );

    if (!passwordValid) {
      throw Exception('Invalid email or password');
    }

    return _createLoginTokens(user);
  }

  Future<Map<String, dynamic>> googleLogin(
    String idToken,
  ) async {
    final normalizedToken = idToken.trim();

    if (normalizedToken.isEmpty) {
      throw Exception(
        'Google ID token is required',
      );
    }

    final googleUser = await googleAuthService.verifyIdToken(
      normalizedToken,
    );

    final providerId = googleUser['providerId']?.toString();

    final email = googleUser['email']?.toString().trim().toLowerCase();

    final name = googleUser['name']?.toString().trim();

    if (providerId == null || providerId.isEmpty) {
      throw Exception(
        'Google user ID is missing',
      );
    }

    if (email == null || email.isEmpty) {
      throw Exception(
        'Google email is missing',
      );
    }

    if (name == null || name.isEmpty) {
      throw Exception(
        'Google user name is missing',
      );
    }

    User? user = await repository.findByProviderId(
      'GOOGLE',
      providerId,
    );

    if (user == null) {
      user = await repository.findByEmail(email);
    }

    final now = DateTime.now();

    if (user == null) {
      user = await repository.create(
        User(
          name: name,
          email: email,
          password: null,
          role: RoleConstants.user,
          provider: 'GOOGLE',
          providerId: providerId,
          isActive: true,
          isEmailVerified: true,
          emailVerifiedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      if (!user.isActive) {
        throw Exception(
          'User account is inactive',
        );
      }

      final isGoogleAccount = user.provider.toUpperCase() == 'GOOGLE';

      final sameGoogleUser = user.providerId == providerId;

      if (!isGoogleAccount || !sameGoogleUser) {
        if (user.id == null) {
          throw Exception(
            'User ID is missing',
          );
        }

        final updatedUser = await repository.updateById(
          user.id!.oid,
          {
            'provider': 'GOOGLE',
            'providerId': providerId,
            'isEmailVerified': true,
            'emailVerifiedAt': user.emailVerifiedAt ?? now,
          },
        );

        if (updatedUser == null) {
          throw Exception(
            'Failed to update user',
          );
        }

        user = updatedUser;
      }
    }

    return _createLoginTokens(user);
  }

  Future<Map<String, dynamic>> _createLoginTokens(
    User user,
  ) async {
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

    final refreshTokenHash = TokenHashUtil.hash(refreshToken);

    final refreshExpiresAt = DateTime.now().add(
      Duration(
        seconds: Env.jwtRefreshExpires,
      ),
    );

    await refreshTokenSessionRepository.create(
      RefreshTokenSession(
        userId: user.id!,
        tokenHash: refreshTokenHash,
        expiresAt: refreshExpiresAt,
        revokedAt: null,
        createdAt: DateTime.now(),
      ),
    );

    return {
      'user': UserResponse.fromUser(user).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

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

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    if (user.password == null || user.password!.isEmpty) {
      if (user.provider.toUpperCase() == 'GOOGLE') {
        throw Exception(
          'Google accounts cannot change password using this endpoint',
        );
      }

      throw Exception(
        'Password is not configured for this account',
      );
    }

    final valid = PasswordUtil.verify(
      currentPassword,
      user.password!,
    );

    if (!valid) {
      throw Exception(
        'Current password is incorrect',
      );
    }

    final hashedPassword = PasswordUtil.hash(newPassword);

    await repository.updateById(
      userId,
      {
        'password': hashedPassword,
        'provider': 'LOCAL',
        'providerId': null,
      },
    );

    if (user.id != null) {
      await refreshTokenSessionRepository.revokeAllByUserId(user.id!);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

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

    final otp = OtpUtil.generate6DigitOtp();

    final otpHash = OtpHashUtil.hash(otp);

    final expiresAt = DateTime.now().add(
      Duration(
        minutes: Env.emailVerificationExpiresMinutes,
      ),
    );

    await otpRepository.deleteByUserId(
      user.id!,
    );

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

    await emailService.sendVerificationOtp(
      toEmail: user.email,
      name: user.name,
      otp: otp,
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final normalizedOtp = otp.trim();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'Email is required',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw Exception(
        'OTP must be 6 digits',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null) {
      throw Exception(
        'Invalid or expired OTP',
      );
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    if (user.isEmailVerified) {
      throw Exception(
        'Email is already verified',
      );
    }

    if (user.id == null) {
      throw Exception(
        'User ID is missing',
      );
    }

    final otpDocument = await otpRepository.findActiveOtp(
      userId: user.id!,
    );

    if (otpDocument == null) {
      throw Exception(
        'Invalid or expired OTP',
      );
    }

    final rawOtpId = otpDocument['_id'];

    if (rawOtpId is! ObjectId) {
      throw Exception(
        'Invalid verification OTP',
      );
    }

    final attempts = otpDocument['attempts'] as int? ?? 0;

    const maxAttempts = 5;

    if (attempts >= maxAttempts) {
      throw Exception(
        'Too many invalid attempts. Please request a new OTP.',
      );
    }

    final otpHash = OtpHashUtil.hash(
      normalizedOtp,
    );

    final savedOtpHash = otpDocument['otpHash']?.toString();

    if (savedOtpHash != otpHash) {
      await otpRepository.incrementAttempts(
        rawOtpId,
      );

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

    await otpRepository.markUsed(
      rawOtpId,
    );

    await repository.updateById(
      user.id!.oid,
      {
        'isEmailVerified': true,
        'emailVerifiedAt': DateTime.now(),
      },
    );
  }

  Future<void> resendVerification(
    String email,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || !_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null || user.isEmailVerified || !user.isActive) {
      return;
    }

    await _sendVerificationOtp(user);
  }

  Future<void> forgotPassword(
    String email,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'Email is required',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null || !user.isActive) {
      return;
    }

    if (user.id == null) {
      return;
    }

    if (user.password == null || user.password!.isEmpty) {
      if (user.provider.toUpperCase() == 'GOOGLE') {
        return;
      }

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
      throw Exception(
        'Email is required',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw Exception(
        'OTP must be 6 digits',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null || user.id == null) {
      throw Exception(
        'Invalid or expired OTP',
      );
    }

    if (!user.isActive) {
      throw Exception(
        'Invalid or expired OTP',
      );
    }

    if (user.password == null || user.password!.isEmpty) {
      throw Exception(
        'This account does not use password login',
      );
    }

    final otpDocument = await passwordResetOtpRepository.findActiveOtp(
      userId: user.id!,
    );

    if (otpDocument == null) {
      throw Exception(
        'Invalid or expired OTP',
      );
    }

    final rawOtpId = otpDocument['_id'];

    if (rawOtpId is! ObjectId) {
      throw Exception(
        'Invalid reset OTP',
      );
    }

    final attempts = otpDocument['attempts'] as int? ?? 0;

    const maxAttempts = 5;

    if (attempts >= maxAttempts) {
      throw Exception(
        'Too many invalid attempts. Please request a new OTP.',
      );
    }

    final otpHash = OtpHashUtil.hash(
      normalizedOtp,
    );

    final savedOtpHash = otpDocument['otpHash']?.toString();

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
        'Invalid OTP. Attempt $currentAttempt of $maxAttempts.',
      );
    }

    final resetToken = PasswordResetTokenUtil.generate();

    final tokenHash = TokenHashUtil.hash(
      resetToken,
    );

    await passwordResetSessionRepository.deleteByUserId(
      user.id!,
    );

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

    await passwordResetOtpRepository.markUsed(
      rawOtpId,
    );

    return resetToken;
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final normalizedToken = resetToken.trim();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'Email is required',
      );
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception(
        'Invalid email address',
      );
    }

    if (normalizedToken.isEmpty) {
      throw Exception(
        'Reset token is required',
      );
    }

    if (newPassword.isEmpty) {
      throw Exception(
        'New password is required',
      );
    }

    if (newPassword.length < 8) {
      throw Exception(
        'Password must be at least 8 characters',
      );
    }

    final user = await repository.findByEmail(
      normalizedEmail,
    );

    if (user == null) {
      throw Exception(
        'Invalid or expired reset token',
      );
    }

    if (user.id == null) {
      throw Exception(
        'User ID is missing',
      );
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    if (user.password == null || user.password!.isEmpty) {
      throw Exception(
        'This account does not use password login',
      );
    }

    final tokenHash = TokenHashUtil.hash(
      normalizedToken,
    );

    final session = await passwordResetSessionRepository.findValidSession(
      userId: user.id!,
      tokenHash: tokenHash,
    );

    if (session == null) {
      throw Exception(
        'Invalid or expired reset token',
      );
    }

    final rawSessionId = session['_id'];

    if (rawSessionId is! ObjectId) {
      throw Exception(
        'Invalid reset session',
      );
    }

    final hashedPassword = PasswordUtil.hash(
      newPassword,
    );

    await repository.updateById(
      user.id!.oid,
      {
        'password': hashedPassword,
        'provider': 'LOCAL',
        'providerId': null,
      },
    );

    await passwordResetSessionRepository.markUsed(
      rawSessionId,
    );

    await refreshTokenSessionRepository.revokeAllByUserId(
      user.id!,
    );
  }

  Future<Map<String, dynamic>> refresh(
    String refreshToken,
  ) async {
    final normalizedToken = refreshToken.trim();

    if (normalizedToken.isEmpty) {
      throw Exception(
        'Refresh token is required',
      );
    }

    final payload = JwtUtil.verify(
      normalizedToken,
    );

    final tokenType = payload['type']?.toString();

    if (tokenType != 'refresh') {
      throw Exception(
        'Invalid refresh token',
      );
    }

    final rawUserId = payload['userId']?.toString();

    if (rawUserId == null || rawUserId.isEmpty) {
      throw Exception(
        'Invalid refresh token',
      );
    }

    final userId = ObjectId.fromHexString(
      rawUserId,
    );

    final user = await repository.findById(
      userId.oid,
    );

    if (user == null) {
      throw Exception(
        'User not found',
      );
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    final tokenHash = TokenHashUtil.hash(
      normalizedToken,
    );

    final session = await refreshTokenSessionRepository.findValidSession(
      userId: userId,
      tokenHash: tokenHash,
    );

    if (session == null) {
      throw Exception(
        'Invalid or expired refresh token',
      );
    }

    final rawSessionId = session['_id'];

    if (rawSessionId is! ObjectId) {
      throw Exception(
        'Invalid refresh session',
      );
    }

    await refreshTokenSessionRepository.revokeSession(
      rawSessionId,
    );

    final newAccessToken = JwtUtil.generateAccessToken(
      userId: user.id!.oid,
      email: user.email,
      role: user.role,
    );

    final newRefreshToken = JwtUtil.generateRefreshToken(
      userId: user.id!.oid,
    );

    final newRefreshTokenHash = TokenHashUtil.hash(
      newRefreshToken,
    );

    final refreshExpiresAt = DateTime.now().add(
      Duration(
        seconds: Env.jwtRefreshExpires,
      ),
    );

    await refreshTokenSessionRepository.create(
      RefreshTokenSession(
        userId: user.id!,
        tokenHash: newRefreshTokenHash,
        expiresAt: refreshExpiresAt,
        revokedAt: null,
        createdAt: DateTime.now(),
      ),
    );

    return {
      'accessToken': newAccessToken,
      'refreshToken': newRefreshToken,
    };
  }

  Future<void> logout(
    String refreshToken,
  ) async {
    final normalizedToken = refreshToken.trim();

    if (normalizedToken.isEmpty) {
      throw Exception(
        'Refresh token is required',
      );
    }

    final payload = JwtUtil.verify(
      normalizedToken,
    );

    final tokenType = payload['type']?.toString();

    if (tokenType != 'refresh') {
      throw Exception(
        'Invalid refresh token',
      );
    }

    final rawUserId = payload['userId']?.toString();

    if (rawUserId == null || rawUserId.isEmpty) {
      throw Exception(
        'Invalid refresh token',
      );
    }

    final userId = ObjectId.fromHexString(
      rawUserId,
    );

    final tokenHash = TokenHashUtil.hash(
      normalizedToken,
    );

    final session = await refreshTokenSessionRepository.findValidSession(
      userId: userId,
      tokenHash: tokenHash,
    );

    if (session == null) {
      throw Exception(
        'Invalid or expired refresh token',
      );
    }

    final rawSessionId = session['_id'];

    if (rawSessionId is! ObjectId) {
      throw Exception(
        'Invalid refresh session',
      );
    }

    await refreshTokenSessionRepository.revokeSession(
      rawSessionId,
    );
  }
}
