import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../dto/request/order/checkout_request.dart';
import '../models/auth/authenticated_user.dart';
import '../services/order_service.dart';

class OrderController {
  final OrderService service;

  OrderController(this.service);

  ObjectId _userId(RequestContext context) {
    final authenticatedUser = context.read<AuthenticatedUser>();
    final userId = authenticatedUser.userId;

    if (!ObjectId.isValidHexId(userId)) {
      throw FormatException('Invalid authenticated user ID');
    }

    return ObjectId.fromHexString(userId);
  }

  ObjectId _parseId(String value) {
    if (!ObjectId.isValidHexId(value)) {
      throw FormatException('Invalid order ID');
    }

    return ObjectId.fromHexString(value);
  }

  Future<Response> checkout(RequestContext context) async {
    try {
      final body = await context.request.json();

      if (body is! Map<String, dynamic>) {
        throw FormatException('Invalid request body');
      }

      final request = CheckoutRequest.fromJson(body);

      final result = await service.checkout(
        userId: _userId(context),
        request: request,
      );

      return Response.json(
        statusCode: 201,
        body: {
          'success': true,
          'message': 'Order created successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> getOrders(RequestContext context) async {
    try {
      final result = await service.getOrders(_userId(context));

      return Response.json(
        body: {
          'success': true,
          'message': 'Orders retrieved successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> getOrderDetail(
    RequestContext context,
    String id,
  ) async {
    try {
      final result = await service.getOrderDetail(
        userId: _userId(context),
        orderId: _parseId(id),
      );

      return Response.json(
        body: {
          'success': true,
          'message': 'Order retrieved successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> cancelOrder(
    RequestContext context,
    String id,
  ) async {
    try {
      final result = await service.cancelOrder(
        userId: _userId(context),
        orderId: _parseId(id),
      );

      return Response.json(
        body: {
          'success': true,
          'message': 'Order cancelled successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Response _errorResponse(Object error) {
    final message = error is FormatException
        ? error.message
        : error.toString().replaceFirst('Exception: ', '');

    final normalized = message.toLowerCase();

    final statusCode = error is FormatException
        ? 400
        : normalized.contains('not found')
        ? 404
        : normalized.contains('stock') ||
              normalized.contains('empty') ||
              normalized.contains('cancelled')
        ? 409
        : 400;

    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'message': message,
        'data': null,
      },
    );
  }
}
