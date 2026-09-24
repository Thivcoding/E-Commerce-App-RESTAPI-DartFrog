
import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/utils/response_util.dart';

Future<Response> onRequest(RequestContext context) async {
  return ResponseUtil.success(
    message: 'Refresh endpoint is ready',
  );
}