import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/middleware/auth_middleware.dart';
import 'package:ecommerce_api/middleware/role_middleware.dart';

Handler middleware(
  Handler handler,
) {
  return AuthMiddleware.required()(
    RoleMiddleware.required('USER')(
      handler,
    ),
  );
}