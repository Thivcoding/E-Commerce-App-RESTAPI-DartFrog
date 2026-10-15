import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/category_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/middleware/role_middleware.dart';
import 'package:ecommerce_api/utils/category_service_factory.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final controller = CategoryController(
    createCategoryService(),
  );

  switch (context.request.method) {
    case HttpMethod.get:
      return controller.findById(
        context,
        id,
      );

    case HttpMethod.put:
      return AuthMiddleware.required()(
        RoleMiddleware.required(
          'ADMIN',
        )(
          (context) => controller.update(
            context,
            id,
          ),
        ),
      )(context);

    case HttpMethod.delete:
      return AuthMiddleware.required()(
        RoleMiddleware.required(
          'ADMIN',
        )(
          (context) => controller.delete(
            context,
            id,
          ),
        ),
      )(context);

    default:
      return Response(
        statusCode: 405,
        headers: {
          'Allow': 'GET, PUT, DELETE',
        },
        body: 'Method Not Allowed',
      );
  }
}
