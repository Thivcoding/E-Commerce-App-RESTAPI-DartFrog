import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/middleware/auth_middleware.dart';

Handler middleware(Handler handler) {
  return AuthMiddleware.required()(handler);
}