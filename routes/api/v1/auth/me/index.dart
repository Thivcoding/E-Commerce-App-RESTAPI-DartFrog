import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/auth_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/models/authenticated_user.dart';
import 'package:ecommerce_api/utils/auth_service_factory.dart';

Future<Response> onRequest(RequestContext context) async {
  return AuthMiddleware.required()(
    (context) async {
      final authenticatedUser =
          context.read<AuthenticatedUser>();

      final service = createAuthService();
      final controller = AuthController(service);

      return controller.me(
        context,
        authenticatedUser.userId,
      );
    },
  )(context);
}