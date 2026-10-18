import 'package:mongo_dart/mongo_dart.dart';

class OrderItem {
  final ObjectId id;
  final ObjectId orderId;
  final ObjectId productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      '_id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'createdAt': createdAt,
    };
  }

  factory OrderItem.fromDocument(Map<String, dynamic> document) {
    return OrderItem(
      id: document['_id'] as ObjectId,
      orderId: document['orderId'] as ObjectId,
      productId: document['productId'] as ObjectId,
      productName: document['productName'] as String,
      productImage: document['productImage'] as String?,
      unitPrice: (document['unitPrice'] as num).toDouble(),
      quantity: (document['quantity'] as num).toInt(),
      subtotal: (document['subtotal'] as num).toDouble(),
      createdAt: document['createdAt'] as DateTime,
    );
  }
}
