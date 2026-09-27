import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/dto/request/forgot_password_request.dart';
import 'package:ecommerce_api/dto/request/login_request.dart';
import 'package:ecommerce_api/dto/request/register_request.dart';
import 'package:ecommerce_api/dto/request/reset_password_request.dart';
import 'package:ecommerce_api/dto/request/verify_email_request.dart';
import 'package:ecommerce_api/dto/request/verify_reset_otp_request.dart';
import 'package:ecommerce_api/services/auth_service.dart';
import 'package:ecommerce_api/utils/response_util.dart';

class AuthController {
  final AuthService authService;

  AuthController(this.authService);

  // =========================================================
  // REGISTER
  // =========================================================

  Future<Response> register(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final data = Map<String, dynamic>.from(body);

      final request = RegisterRequest.fromJson(data);

      final result = await authService.register(request);

      return ResponseUtil.success(
        message: 'Registration successful',
        data: result.toJson(),
        statusCode: 201,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Response> login(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final data = Map<String, dynamic>.from(body);

      final request = LoginRequest.fromJson(data);

      final result = await authService.login(request);

      return ResponseUtil.success(
        message: 'Login successful',
        data: result,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 401,
      );
    }
  }

  // =========================================================
  // VERIFY EMAIL WITH OTP
  // =========================================================

  Future<Response> verifyEmail(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final data = Map<String, dynamic>.from(body);

      final request = VerifyEmailRequest.fromJson(data);

      await authService.verifyEmail(
        email: request.email,
        otp: request.otp,
      );

      return ResponseUtil.success(
        message: 'Email verified successfully',
        data: null,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // GET ME
  // =========================================================

  Future<Response> me(
    RequestContext context,
    String userId,
  ) async {
    try {
      final user = await authService.getMe(userId);

      return ResponseUtil.success(
        message: 'User information retrieved successfully',
        data: user.toJson(),
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // RESEND VERIFICATION OTP
  // =========================================================

  Future<Response> resendVerification(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final data = Map<String, dynamic>.from(body);

      final email = data['email']?.toString() ?? '';

      await authService.resendVerification(email);

      return ResponseUtil.success(
        message:
            'If the account exists and needs verification, '
            'a verification email will be sent.',
        data: null,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // FORGOT PASSWORD
  // =========================================================

  Future<Response> forgotPassword(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = ForgotPasswordRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      await authService.forgotPassword(
        request.email,
      );

      return ResponseUtil.success(
        message:
            'If the email exists, a password reset OTP has been sent.',
        data: null,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // VERIFY PASSWORD RESET OTP
  // =========================================================

  Future<Response> verifyResetOtp(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = VerifyResetOtpRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      final resetToken =
          await authService.verifyPasswordResetOtp(
        email: request.email,
        otp: request.otp,
      );

      return ResponseUtil.success(
        message: 'OTP verified successfully',
        data: {
          'resetToken': resetToken,
        },
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }

  // =========================================================
  // RESET PASSWORD
  // =========================================================

  Future<Response> resetPassword(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = ResetPasswordRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      await authService.resetPassword(
        email: request.email,
        resetToken: request.resetToken,
        newPassword: request.newPassword,
      );

      return ResponseUtil.success(
        message: 'Password reset successfully',
        data: null,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        statusCode: 400,
      );
    }
  }
}
