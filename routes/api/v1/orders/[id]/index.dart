import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/order_controller.dart';
import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/utils/order_service_factory.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final controller = OrderController(createOrderService());

  if (context.request.method == HttpMethod.get) {
    return AuthMiddleware.required()(
      (context) => controller.getOrderDetail(context, id),
    )(context);
  }

  return Response(
    statusCode: 405,
    headers: {'Allow': 'GET'},
    body: 'Method Not Allowed',
  );
}
