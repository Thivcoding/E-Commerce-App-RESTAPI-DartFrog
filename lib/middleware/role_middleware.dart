import 'package:dart_frog/dart_frog.dart';

import '../models/auth/authenticated_user.dart';

class RoleMiddleware {
  static Middleware required(
    String requiredRole,
  ) {
    return (handler) {
      return (context) async {
        try {
          final authenticatedUser = context.read<AuthenticatedUser>();

          final userRole = authenticatedUser.role.toUpperCase();

          final expectedRole = requiredRole.toUpperCase();

          if (userRole != expectedRole) {
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
              'message': 'Authentication required',
            },
          );
        }
      };
    };
  }
}
