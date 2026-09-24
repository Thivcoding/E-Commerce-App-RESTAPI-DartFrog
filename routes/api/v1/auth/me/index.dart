import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/controllers/auth_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/models/authenticated_user.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  return AuthMiddleware.required()(
    (context) async {
      final authenticatedUser =
          context.read<AuthenticatedUser>();

      final repository = UserRepository(Database.db);
      final service = AuthService(repository);
      final controller = AuthController(service);

      return controller.me(
        context,
        authenticatedUser.userId,
      );
    },
  )(context);
}