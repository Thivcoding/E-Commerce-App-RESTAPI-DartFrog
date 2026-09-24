import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:ecommerce_api/dto/request/login_request.dart';
import 'package:ecommerce_api/dto/request/register_request.dart';
import 'package:ecommerce_api/services/auth_service.dart';
import 'package:ecommerce_api/utils/response_util.dart';

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

      final data = Map<String, dynamic>.from(
        body,
      );

      final request = RegisterRequest.fromJson(data);

      final result = await authService.register(request);

      return ResponseUtil.success(
        message: 'Registration successful',
        data: result.toJson(),
        statusCode: 201,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString(),
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

      final data = Map<String, dynamic>.from(
        body,
      );

      final request = LoginRequest.fromJson(data);

      final result = await authService.login(request);

      return ResponseUtil.success(
        message: 'Login successful',
        data: result,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: e.toString(),
        statusCode: 401,
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
        message: e.toString().replaceFirst('Exception: ', ''),
        statusCode: 400,
      );
    }
  }
}
