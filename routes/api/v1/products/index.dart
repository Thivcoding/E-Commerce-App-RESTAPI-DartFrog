import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/models/auth/authenticated_user.dart';

Future<Response> onRequest(
  RequestContext context,
) async {
  if (context.request.method != HttpMethod.get) {
    return Response(
      statusCode: 405,
      body: 'Method Not Allowed',
    );
  }

  final user = context.read<AuthenticatedUser>();

  return Response.json(
    body: {
      'success': true,
      'message': 'Admin access granted',
      'data': {
        'userId': user.userId,
        'email': user.email,
        'role': user.role,
      },
    },
  );
}
