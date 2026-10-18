import 'package:mongo_dart/mongo_dart.dart';

import '../dto/request/order/checkout_request.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../repositories/cart_item_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_item_repository.dart';
import '../repositories/order_repository.dart';

class OrderService {
  final Db db;
  final CartRepository cartRepository;
  final CartItemRepository cartItemRepository;
  final OrderRepository orderRepository;
  final OrderItemRepository orderItemRepository;

  OrderService({
    required this.db,
    required this.cartRepository,
    required this.cartItemRepository,
    required this.orderRepository,
    required this.orderItemRepository,
  });

  DbCollection get products => db.collection('products');

  Future<Map<String, dynamic>> checkout({
    required ObjectId userId,
    required CheckoutRequest request,
  }) async {
    final cart = await cartRepository.findActiveByUserId(userId);

    if (cart == null) {
      throw Exception('Cart is empty');
    }

    final cartItems = await cartItemRepository.findByCartId(cart.id);

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    final productSnapshots = <Map<String, dynamic>>[];
    double totalAmount = 0;

    for (final cartItem in cartItems) {
      if (cartItem.quantity <= 0) {
        throw Exception('Product quantity must be greater than zero');
      }

      final product = await products.findOne(
        where.eq('_id', cartItem.productId),
      );

      if (product == null || product['isActive'] != true) {
        throw Exception('Product is not available');
      }

      final price = (product['price'] as num?)?.toDouble();
      final stock = (product['stock'] as num?)?.toInt() ?? 0;

      if (price == null || !price.isFinite || price <= 0) {
        throw Exception('Product price is invalid');
      }

      if (stock < 0) {
        throw Exception('Product stock is invalid');
      }

      if (cartItem.quantity > stock) {
        throw Exception('Insufficient stock for ${product['name']}');
      }

      final subtotal = price * cartItem.quantity;

      totalAmount += subtotal;

      productSnapshots.add({
        'cartItem': cartItem,
        'productId': cartItem.productId,
        'productName': product['name']?.toString() ?? 'Unknown Product',
        'productImage': product['image']?.toString(),
        'unitPrice': price,
        'quantity': cartItem.quantity,
        'subtotal': subtotal,
      });
    }

    final now = DateTime.now();
    final orderId = ObjectId();

    final order = Order(
      id: orderId,
      userId: userId,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
      shippingAddress: request.shippingAddress,
      status: 'PENDING',
      paymentStatus: 'UNPAID',
      paymentMethod: request.paymentMethod,
      totalAmount: totalAmount,
      currency: 'USD',
      createdAt: now,
      updatedAt: now,
    );

    final orderItems = productSnapshots.map((snapshot) {
      return OrderItem(
        id: ObjectId(),
        orderId: orderId,
        productId: snapshot['productId'] as ObjectId,
        productName: snapshot['productName'] as String,
        productImage: snapshot['productImage'] as String?,
        unitPrice: snapshot['unitPrice'] as double,
        quantity: snapshot['quantity'] as int,
        subtotal: snapshot['subtotal'] as double,
        createdAt: now,
      );
    }).toList();

    final reservedProducts = <Map<String, dynamic>>[];

    try {
      for (final snapshot in productSnapshots) {
        final productId = snapshot['productId'] as ObjectId;
        final quantity = snapshot['quantity'] as int;

        final result = await products.updateOne(
          where
              .eq('_id', productId)
              .eq('isActive', true)
              .gte('stock', quantity),
          modify.inc('stock', -quantity),
        );

        if (result.nMatched == 0) {
          throw Exception(
            'Insufficient stock for ${snapshot['productName']}',
          );
        }

        reservedProducts.add({
          'productId': productId,
          'quantity': quantity,
        });
      }

      await orderRepository.create(order);
      await orderItemRepository.createMany(orderItems);
      await cartItemRepository.deleteByCartId(cart.id);
      await cartRepository.updateTimestamp(cart.id);
    } catch (_) {
      for (final reserved in reservedProducts.reversed) {
        await products.updateOne(
          where.eq('_id', reserved['productId'] as ObjectId),
          modify.inc('stock', reserved['quantity'] as int),
        );
      }

      await orderItemRepository.deleteByOrderId(orderId);
      await orderRepository.deleteById(orderId);

      rethrow;
    }

    return getOrderDetail(
      userId: userId,
      orderId: orderId,
    );
  }

  Future<List<Map<String, dynamic>>> getOrders(
    ObjectId userId,
  ) async {
    final orders = await orderRepository.findByUserId(userId);

    return orders.map((order) {
      return {
        'id': order.id.toHexString(),
        'status': order.status,
        'fullName': order.fullName,
        'phoneNumber': order.phoneNumber,
        'shippingAddress': order.shippingAddress,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus,
        'totalAmount': order.totalAmount,
        'currency': order.currency,
        'createdAt': order.createdAt.toIso8601String(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> getOrderDetail({
    required ObjectId userId,
    required ObjectId orderId,
  }) async {
    final order = await orderRepository.findByIdAndUserId(
      orderId,
      userId,
    );

    if (order == null) {
      throw Exception('Order not found');
    }

    final items = await orderItemRepository.findByOrderId(order.id);

    return {
      'id': order.id.toHexString(),
      'status': order.status,
      'paymentStatus': order.paymentStatus,
      'fullName': order.fullName,
      'phoneNumber': order.phoneNumber,
      'shippingAddress': order.shippingAddress,
      'paymentMethod': order.paymentMethod,
      'totalAmount': order.totalAmount,
      'currency': order.currency,
      'createdAt': order.createdAt.toIso8601String(),
      'updatedAt': order.updatedAt.toIso8601String(),
      'items': items.map((item) {
        return {
          'id': item.id.toHexString(),
          'productId': item.productId.toHexString(),
          'productName': item.productName,
          'productImage': item.productImage,
          'unitPrice': item.unitPrice,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList(),
    };
  }

  Future<Map<String, dynamic>> cancelOrder({
    required ObjectId userId,
    required ObjectId orderId,
  }) async {
    final order = await orderRepository.findByIdAndUserId(
      orderId,
      userId,
    );

    if (order == null) {
      throw Exception('Order not found');
    }

    if (order.status != 'PENDING') {
      throw Exception('Only pending orders can be cancelled');
    }

    final items = await orderItemRepository.findByOrderId(order.id);

    for (final item in items) {
      await products.updateOne(
        where.eq('_id', item.productId),
        modify.inc('stock', item.quantity),
      );
    }

    await orderRepository.updateStatus(
      orderId: order.id,
      status: 'CANCELLED',
      paymentStatus: order.paymentStatus,
    );

    return getOrderDetail(
      userId: userId,
      orderId: orderId,
    );
  }
}
