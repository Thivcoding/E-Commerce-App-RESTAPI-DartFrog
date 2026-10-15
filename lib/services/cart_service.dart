import 'package:mongo_dart/mongo_dart.dart';

import '../dto/request/cart/add_cart_item_request.dart';
import '../repositories/cart_item_repository.dart';
import '../repositories/cart_repository.dart';
import '../models/cart.dart';

class CartService {
  final Db db;
  final CartRepository cartRepository;
  final CartItemRepository itemRepository;

  CartService({
    required this.db,
    required this.cartRepository,
    required this.itemRepository,
  });

  DbCollection get products => db.collection('products');

  Future<Cart> _getOrCreateCart(ObjectId userId) async {
    final cart = await cartRepository.findActiveByUserId(userId);

    if (cart != null) {
      return cart;
    }

    return cartRepository.createForUser(userId);
  }

  Future<Map<String, dynamic>> getCart(
    ObjectId userId,
  ) async {
    final cart = await _getOrCreateCart(userId);
    final items = await itemRepository.findByCartId(cart.id);

    final resultItems = <Map<String, dynamic>>[];
    double totalAmount = 0;
    int totalItems = 0;

    for (final item in items) {
      final product = await products.findOne(
        where.eq('_id', item.productId),
      );

      if (product == null) {
        continue;
      }

      final subtotal = item.price * item.quantity;

      totalAmount += subtotal;
      totalItems += item.quantity;

      resultItems.add({
        'id': item.id.toHexString(),
        'product': {
          'id': item.productId.toHexString(),
          'name': product['name'],
          'price': item.price,
          'currentPrice': product['price'],
          'image': product['image'],
        },
        'quantity': item.quantity,
        'subtotal': subtotal,
      });
    }

    return {
      'cartId': cart.id.toHexString(),
      'status': cart.status,
      'items': resultItems,
      'totalItems': totalItems,
      'totalAmount': totalAmount,
      'currency': 'USD',
    };
  }

  Future<Map<String, dynamic>> addItem(
    ObjectId userId,
    AddCartItemRequest request,
  ) async {
    final product = await products.findOne(
      where.eq('_id', request.productId),
    );

    if (product == null) {
      throw Exception('Product not found');
    }

    if (product['isActive'] != true) {
      throw Exception('Product is not available');
    }

    final stock = (product['stock'] as num?)?.toInt() ?? 0;
    final price = (product['price'] as num?)?.toDouble();

    if (price == null || price < 0) {
      throw Exception('Product price is invalid');
    }

    final cart = await _getOrCreateCart(userId);

    final existingItem = await itemRepository.findByCartAndProduct(
      cart.id,
      request.productId,
    );

    final newQuantity = (existingItem?.quantity ?? 0) + request.quantity;

    if (newQuantity > stock) {
      throw Exception('Insufficient product stock');
    }

    if (existingItem != null) {
      await itemRepository.updateQuantity(
        itemId: existingItem.id,
        quantity: newQuantity,
        price: price,
      );
    } else {
      await itemRepository.create(
        cartId: cart.id,
        productId: request.productId,
        quantity: request.quantity,
        price: price,
      );
    }

    await cartRepository.updateTimestamp(cart.id);

    return getCart(userId);
  }

  Future<Map<String, dynamic>> updateItem({
    required ObjectId userId,
    required ObjectId itemId,
    required int quantity,
  }) async {
    final cart = await cartRepository.findActiveByUserId(userId);

    if (cart == null) {
      throw Exception('Cart not found');
    }

    final item = await itemRepository.findByIdAndCart(
      itemId,
      cart.id,
    );

    if (item == null) {
      throw Exception('Cart item not found');
    }

    final product = await products.findOne(
      where.eq('_id', item.productId),
    );

    if (product == null || product['isActive'] != true) {
      throw Exception('Product is not available');
    }

    final stock = (product['stock'] as num?)?.toInt() ?? 0;
    final price = (product['price'] as num?)?.toDouble();

    if (price == null || price < 0) {
      throw Exception('Product price is invalid');
    }

    if (quantity > stock) {
      throw Exception('Insufficient product stock');
    }

    await itemRepository.updateQuantity(
      itemId: item.id,
      quantity: quantity,
      price: price,
    );

    await cartRepository.updateTimestamp(cart.id);

    return getCart(userId);
  }

  Future<Map<String, dynamic>> removeItem({
    required ObjectId userId,
    required ObjectId itemId,
  }) async {
    final cart = await cartRepository.findActiveByUserId(userId);

    if (cart == null) {
      throw Exception('Cart not found');
    }

    final item = await itemRepository.findByIdAndCart(
      itemId,
      cart.id,
    );

    if (item == null) {
      throw Exception('Cart item not found');
    }

    await itemRepository.deleteById(item.id);
    await cartRepository.updateTimestamp(cart.id);

    return getCart(userId);
  }

  Future<Map<String, dynamic>> clearCart(
    ObjectId userId,
  ) async {
    final cart = await cartRepository.findActiveByUserId(userId);

    if (cart == null) {
      return getCart(userId);
    }

    await itemRepository.deleteByCartId(cart.id);
    await cartRepository.updateTimestamp(cart.id);

    return getCart(userId);
  }
}
