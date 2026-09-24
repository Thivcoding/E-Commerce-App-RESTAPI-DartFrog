import 'package:dart_frog/dart_frog.dart';

import '../utils/jwt_util.dart';

class RoleMiddleware {
  static Middleware required(
    String requiredRole,
  ) {
    return (handler) {
      return (context) async {
        final authorization = context.request.headers['authorization'];

        if (authorization == null || !authorization.startsWith('Bearer ')) {
          return Response.json(
            statusCode: 401,
            body: {
              'success': false,
              'message': 'Authorization token is required',
            },
          );
        }

        final token = authorization.substring(7).trim();

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

          final role = payload['role']?.toString();

          if (role != requiredRole) {
            return Response.json(
              statusCode: 403,
              body: {
                'success': false,
                'message': 'Access denied',
              },
            );
          }

          return handler(context);
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
