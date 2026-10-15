import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../dto/request/cart/add_cart_item_request.dart';
import '../dto/request/cart/update_cart_item_request.dart';
import '../models/auth/authenticated_user.dart';
import '../services/cart_service.dart';

class CartController {
  final CartService service;

  CartController(this.service);

  ObjectId _userId(RequestContext context) {
    final authenticatedUser = context.read<AuthenticatedUser>();
    final userId = authenticatedUser.userId;

    if (!ObjectId.isValidHexId(userId)) {
      throw FormatException('Invalid authenticated user ID');
    }

    return ObjectId.fromHexString(userId);
  }

  Future<Response> getCart(RequestContext context) async {
    try {
      final userId = _userId(context);
      final result = await service.getCart(userId);

      return Response.json(
        body: {
          'success': true,
          'message': 'Cart retrieved successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> addItem(RequestContext context) async {
    try {
      final body = await context.request.json();

      if (body is! Map<String, dynamic>) {
        throw FormatException('Invalid request body');
      }

      final request = AddCartItemRequest.fromJson(body);
      final userId = _userId(context);

      final result = await service.addItem(
        userId,
        request,
      );

      return Response.json(
        statusCode: 201,
        body: {
          'success': true,
          'message': 'Product added to cart successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> updateItem(
    RequestContext context,
    String itemId,
  ) async {
    try {
      final parsedId = _parseId(itemId);
      final body = await context.request.json();

      if (body is! Map<String, dynamic>) {
        throw FormatException('Invalid request body');
      }

      final request = UpdateCartItemRequest.fromJson(body);
      final userId = _userId(context);

      final result = await service.updateItem(
        userId: userId,
        itemId: parsedId,
        quantity: request.quantity,
      );

      return Response.json(
        body: {
          'success': true,
          'message': 'Cart item updated successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> removeItem(
    RequestContext context,
    String itemId,
  ) async {
    try {
      final parsedId = _parseId(itemId);
      final userId = _userId(context);

      final result = await service.removeItem(
        userId: userId,
        itemId: parsedId,
      );

      return Response.json(
        body: {
          'success': true,
          'message': 'Cart item removed successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  Future<Response> clearCart(RequestContext context) async {
    try {
      final userId = _userId(context);
      final result = await service.clearCart(userId);

      return Response.json(
        body: {
          'success': true,
          'message': 'Cart cleared successfully',
          'data': result,
        },
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  ObjectId _parseId(String value) {
    if (!ObjectId.isValidHexId(value)) {
      throw FormatException('Invalid cart item ID');
    }

    return ObjectId.fromHexString(value);
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
        : normalized.contains('stock') || normalized.contains('not available')
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
