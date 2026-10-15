import 'package:mongo_dart/mongo_dart.dart';

class CartItem {
  final ObjectId id;
  final ObjectId cartId;
  final ObjectId productId;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromDocument(Map<String, dynamic> document) {
    return CartItem(
      id: document['_id'] as ObjectId,
      cartId: document['cartId'] as ObjectId,
      productId: document['productId'] as ObjectId,
      quantity: (document['quantity'] as num).toInt(),
      price: (document['price'] as num).toDouble(),
      createdAt: document['createdAt'] is DateTime
          ? document['createdAt'] as DateTime
          : DateTime.now(),
      updatedAt: document['updatedAt'] is DateTime
          ? document['updatedAt'] as DateTime
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      '_id': id,
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  double get subtotal => price * quantity;
}
