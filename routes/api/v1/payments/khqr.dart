import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/controllers/payment_controller.dart';
import 'package:ecommerce_api/models/auth/authenticated_user.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {
        'success': false,
        'message': 'Method not allowed',
      },
    );
  }

  try {
    final user = context.read<AuthenticatedUser>();
    final rawBody = await context.request.body();
    final decoded = jsonDecode(rawBody);

    if (decoded is! Map) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'Invalid request body',
        },
      );
    }

    final body = Map<String, dynamic>.from(decoded);
    final orderId = body['orderId']?.toString() ?? '';

    final controller = PaymentController(db: Database.db);

    final result = await controller.createKhqrPayment(
      userId: ObjectId.fromHexString(user.userId),
      orderId: orderId,
    );

    return Response.json(
      body: {
        'success': true,
        'data': result,
      },
    );
  } on FormatException catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': e.message,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': e.toString(),
      },
    );
  }
}
