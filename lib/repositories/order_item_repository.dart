import 'package:mongo_dart/mongo_dart.dart';

import '../models/order_item.dart';

class OrderItemRepository {
  final DbCollection collection;

  OrderItemRepository(Db db) : collection = db.collection('order_items');

  Future<void> create(OrderItem item) async {
    await collection.insertOne(item.toDocument());
  }

  Future<void> createMany(List<OrderItem> items) async {
    for (final item in items) {
      await create(item);
    }
  }

  Future<List<OrderItem>> findByOrderId(ObjectId orderId) async {
    final documents = await collection
        .find(where.eq('orderId', orderId))
        .toList();

    return documents.map(OrderItem.fromDocument).toList();
  }

  Future<void> deleteByOrderId(ObjectId orderId) async {
    await collection.deleteMany(where.eq('orderId', orderId));
  }
}
