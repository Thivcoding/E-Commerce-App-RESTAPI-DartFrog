import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/cart_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/utils/cart_service_factory.dart';

Future<Response> onRequest(RequestContext context) async {
  final controller = CartController(createCartService());

  switch (context.request.method) {
    case HttpMethod.get:
      return AuthMiddleware.required()(
        controller.getCart,
      )(context);

    default:
      return Response(
        statusCode: 405,
        headers: {'Allow': 'GET'},
        body: 'Method Not Allowed',
      );
  }
}
