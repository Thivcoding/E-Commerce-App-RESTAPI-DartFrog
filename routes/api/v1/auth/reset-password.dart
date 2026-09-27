import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/controllers/auth_controller.dart';
import 'package:ecommerce_api/utils/auth_service_factory.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(
      statusCode: 405,
      body: 'Method Not Allowed',
    );
  }

  final controller = AuthController(
    createAuthService(),
  );

  return controller.resetPassword(context);
}