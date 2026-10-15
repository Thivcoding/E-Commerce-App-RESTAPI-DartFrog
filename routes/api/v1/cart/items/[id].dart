import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/cart_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/utils/cart_service_factory.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final controller = CartController(createCartService());

  switch (context.request.method) {
    case HttpMethod.patch:
      return AuthMiddleware.required()(
        (context) => controller.updateItem(context, id),
      )(context);

    case HttpMethod.delete:
      return AuthMiddleware.required()(
        (context) => controller.removeItem(context, id),
      )(context);

    default:
      return Response(
        statusCode: 405,
        headers: {'Allow': 'PATCH, DELETE'},
        body: 'Method Not Allowed',
      );
  }
}
