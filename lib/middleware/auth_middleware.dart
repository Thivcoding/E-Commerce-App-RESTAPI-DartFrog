import 'package:dart_frog/dart_frog.dart';

import '../models/auth/authenticated_user.dart';
import '../utils/jwt_util.dart';

class AuthMiddleware {
  static Middleware required() {
    return (handler) {
      return (context) async {
        final authorization =
            context.request.headers['authorization'];

        if (authorization == null ||
            !authorization.startsWith('Bearer ')) {
          return Response.json(
            statusCode: 401,
            body: {
              'success': false,
              'message': 'Authorization token is required',
            },
          );
        }

        final token = authorization.substring(7).trim();

        if (token.isEmpty) {
          return Response.json(
            statusCode: 401,
            body: {
              'success': false,
              'message': 'Authorization token is required',
            },
          );
        }

        try {
          final payload = JwtUtil.verify(token);

          if (payload['type'] != 'access') {
            return Response.json(
              statusCode: 401,
              body: {
                'success': false,
                'message': 'Invalid access token',
              },
            );
          }

          final userId = payload['userId']?.toString();
          final email = payload['email']?.toString() ?? '';
          final role = payload['role']?.toString() ?? 'USER';

          if (userId == null || userId.isEmpty) {
            return Response.json(
              statusCode: 401,
              body: {
                'success': false,
                'message': 'User ID is missing from token',
              },
            );
          }

          final authenticatedUser = AuthenticatedUser(
            userId: userId,
            email: email,
            role: role,
          );

          return handler(
            context.provide<AuthenticatedUser>(
              () => authenticatedUser,
            ),
          );
        } catch (e) {
          return Response.json(
            statusCode: 401,
            body: {
              'success': false,
              'message': 'Invalid or expired token',
            },
          );
        }
      };
    };
  }
}