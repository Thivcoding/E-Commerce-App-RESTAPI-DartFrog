import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/category_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/middleware/role_middleware.dart';
import 'package:ecommerce_api/utils/category_service_factory.dart';

Future<Response> onRequest(
  RequestContext context,
) async {
  final controller = CategoryController(
    createCategoryService(),
  );

  switch (context.request.method) {
    case HttpMethod.get:
      return controller.findAll(
        context,
      );

    case HttpMethod.post:
      return AuthMiddleware.required()(
        RoleMiddleware.required(
          'ADMIN',
        )(
          controller.create,
        ),
      )(context);

    default:
      return Response(
        statusCode: 405,
        headers: {
          'Allow': 'GET, POST',
        },
        body: 'Method Not Allowed',
      );
  }
}
