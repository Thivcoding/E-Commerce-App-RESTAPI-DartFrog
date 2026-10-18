import 'package:mongo_dart/mongo_dart.dart';

import '../models/order.dart';

class OrderRepository {
  final DbCollection collection;

  OrderRepository(Db db) : collection = db.collection('orders');

  Future<void> create(Order order) async {
    await collection.insertOne(order.toDocument());
  }

  Future<Order?> findByIdAndUserId(
    ObjectId orderId,
    ObjectId userId,
  ) async {
    final document = await collection.findOne(
      where.eq('_id', orderId).eq('userId', userId),
    );

    if (document == null) return null;

    return Order.fromDocument(document);
  }

  Future<List<Order>> findByUserId(ObjectId userId) async {
    final documents = await collection
        .find(where.eq('userId', userId))
        .toList();

    final orders = documents.map(Order.fromDocument).toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }

  Future<void> updateStatus({
    required ObjectId orderId,
    required String status,
    required String paymentStatus,
  }) async {
    await collection.updateOne(
      where.eq('_id', orderId),
      modify
          .set('status', status)
          .set('paymentStatus', paymentStatus)
          .set('updatedAt', DateTime.now()),
    );
  }

  Future<void> deleteById(ObjectId orderId) async {
    await collection.deleteOne(where.eq('_id', orderId));
  }
}
