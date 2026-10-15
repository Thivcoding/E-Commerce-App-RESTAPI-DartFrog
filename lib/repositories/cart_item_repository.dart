import 'package:mongo_dart/mongo_dart.dart';

import '../models/cart_item.dart';

class CartItemRepository {
  final DbCollection collection;

  CartItemRepository(Db db) : collection = db.collection('cart_items');

  Future<List<CartItem>> findByCartId(
    ObjectId cartId,
  ) async {
    final documents = await collection
        .find(where.eq('cartId', cartId))
        .toList();

    return documents.map(CartItem.fromDocument).toList();
  }

  Future<CartItem?> findByCartAndProduct(
    ObjectId cartId,
    ObjectId productId,
  ) async {
    final document = await collection.findOne(
      where.eq('cartId', cartId).eq('productId', productId),
    );

    if (document == null) {
      return null;
    }

    return CartItem.fromDocument(document);
  }

  Future<CartItem?> findByIdAndCart(
    ObjectId itemId,
    ObjectId cartId,
  ) async {
    final document = await collection.findOne(
      where.eq('_id', itemId).eq('cartId', cartId),
    );

    if (document == null) {
      return null;
    }

    return CartItem.fromDocument(document);
  }

  Future<CartItem> create({
    required ObjectId cartId,
    required ObjectId productId,
    required int quantity,
    required double price,
  }) async {
    final now = DateTime.now();

    final item = CartItem(
      id: ObjectId(),
      cartId: cartId,
      productId: productId,
      quantity: quantity,
      price: price,
      createdAt: now,
      updatedAt: now,
    );

    await collection.insertOne(item.toDocument());

    return item;
  }

  Future<void> updateQuantity({
    required ObjectId itemId,
    required int quantity,
    required double price,
  }) async {
    await collection.updateOne(
      where.eq('_id', itemId),
      modify
          .set('quantity', quantity)
          .set('price', price)
          .set('updatedAt', DateTime.now()),
    );
  }

  Future<void> deleteById(ObjectId itemId) async {
    await collection.deleteOne(
      where.eq('_id', itemId),
    );
  }

  Future<void> deleteByCartId(ObjectId cartId) async {
    await collection.deleteMany(
      where.eq('cartId', cartId),
    );
  }
}
