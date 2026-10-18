import 'package:mongo_dart/mongo_dart.dart';

class PaymentRepository {
  final DbCollection collection;

  PaymentRepository(Db db) : collection = db.collection('payments');

  Future<Map<String, dynamic>?> findPendingByOrderId(
    ObjectId orderId,
  ) {
    return collection.findOne(
      where.eq('orderId', orderId).eq('status', 'PENDING'),
    );
  }

  Future<Map<String, dynamic>?> findByIdAndUserId({
    required ObjectId paymentId,
    required ObjectId userId,
  }) {
    return collection.findOne(
      where.eq('_id', paymentId).eq('userId', userId),
    );
  }

  Future<Map<String, dynamic>?> findByTransactionHash(
    String hash,
  ) {
    return collection.findOne(
      where.eq('transactionHash', hash),
    );
  }

  Future<void> create(Map<String, dynamic> document) async {
    await collection.insertOne(document);
  }

  Future<void> updateStatus({
    required ObjectId paymentId,
    required String status,
    String? transactionHash,
  }) async {
    final modifier = modify
        .set('status', status)
        .set('updatedAt', DateTime.now());

    if (transactionHash != null) {
      modifier.set('transactionHash', transactionHash);
    }

    await collection.updateOne(
      where.eq('_id', paymentId).eq('status', 'PENDING'),
      modifier,
    );
  }

  Future<bool> claimAsPaid({
    required ObjectId paymentId,
    required String transactionHash,
  }) async {
    final result = await collection.updateOne(
      where.eq('_id', paymentId).eq('status', 'PENDING'),
      modify
          .set('status', 'PAID')
          .set('transactionHash', transactionHash)
          .set('updatedAt', DateTime.now()),
    );

    return result.nMatched > 0;
  }
}
