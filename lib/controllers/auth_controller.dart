import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/dto/request/auth/forgot_password_request.dart';
import 'package:ecommerce_api/dto/request/auth/login_request.dart';
import 'package:ecommerce_api/dto/request/auth/logout_request.dart';
import 'package:ecommerce_api/dto/request/auth/refresh_token_request.dart';
import 'package:ecommerce_api/dto/request/auth/register_request.dart';
import 'package:ecommerce_api/dto/request/auth/reset_password_request.dart';
import 'package:ecommerce_api/dto/request/auth/verify_email_request.dart';
import 'package:ecommerce_api/dto/request/auth/verify_reset_otp_request.dart';
import 'package:ecommerce_api/services/auth_service.dart';
import 'package:ecommerce_api/utils/response_util.dart';
import 'package:ecommerce_api/dto/request/auth/google_login_request.dart';

class AuthController {
  final AuthService authService;

  AuthController(this.authService);

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
        message: 'If the email exists, a password reset OTP has been sent.',
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

      final resetToken = await authService.verifyPasswordResetOtp(
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

  Future<Response> refresh(
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

      final request = RefreshTokenRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      final result = await authService.refresh(
        request.refreshToken,
      );

      return ResponseUtil.success(
        message: 'Token refreshed successfully',
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

  Future<Response> logout(
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

      final request = LogoutRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      await authService.logout(
        request.refreshToken,
      );

      return ResponseUtil.success(
        message: 'Logout successful',
        data: null,
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

  Future<Response> googleLogin(
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

      final request = GoogleLoginRequest.fromJson(
        Map<String, dynamic>.from(
          body,
        ),
      );

      final result = await authService.googleLogin(
        request.idToken,
      );

      return ResponseUtil.success(
        message: 'Google login successful',
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
}
