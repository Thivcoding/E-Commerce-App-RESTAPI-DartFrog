import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/order_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/utils/order_service_factory.dart';

Future<Response> onRequest(RequestContext context) async {
  final controller = OrderController(createOrderService());

  switch (context.request.method) {
    case HttpMethod.get:
      return AuthMiddleware.required()(
        controller.getOrders,
      )(context);

    case HttpMethod.post:
      return AuthMiddleware.required()(
        controller.checkout,
      )(context);

    default:
      return Response(
        statusCode: 405,
        headers: {'Allow': 'GET, POST'},
        body: 'Method Not Allowed',
      );
  }
}
