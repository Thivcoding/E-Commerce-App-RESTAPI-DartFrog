import 'package:mongo_dart/mongo_dart.dart';

import '../models/cart.dart';

class CartRepository {
  final DbCollection collection;

  CartRepository(Db db) : collection = db.collection('carts');

  Future<Cart?> findActiveByUserId(ObjectId userId) async {
    final document = await collection.findOne(
      where.eq('userId', userId).eq('status', 'ACTIVE'),
    );

    if (document == null) {
      return null;
    }

    return Cart.fromDocument(document);
  }

  Future<Cart> createForUser(ObjectId userId) async {
    final now = DateTime.now();

    final cart = Cart(
      id: ObjectId(),
      userId: userId,
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
    );

    await collection.insertOne(cart.toDocument());

    return cart;
  }

  Future<void> updateTimestamp(ObjectId cartId) async {
    await collection.updateOne(
      where.eq('_id', cartId),
      modify.set('updatedAt', DateTime.now()),
    );
  }
}
