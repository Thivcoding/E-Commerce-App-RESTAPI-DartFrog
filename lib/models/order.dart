import 'package:mongo_dart/mongo_dart.dart';

class Order {
  final ObjectId id;
  final ObjectId userId;
  final String fullName;
  final String phoneNumber;
  final String shippingAddress;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      '_id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'currency': currency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Order.fromDocument(Map<String, dynamic> document) {
    return Order(
      id: document['_id'] as ObjectId,
      userId: document['userId'] as ObjectId,
      fullName: document['fullName'] as String? ?? '',
      phoneNumber: document['phoneNumber'] as String? ?? '',
      shippingAddress: document['shippingAddress'] as String,
      status: document['status'] as String,
      paymentStatus: document['paymentStatus'] as String,
      paymentMethod: document['paymentMethod'] as String,
      totalAmount: (document['totalAmount'] as num).toDouble(),
      currency: document['currency'] as String,
      createdAt: document['createdAt'] as DateTime,
      updatedAt: document['updatedAt'] as DateTime,
    );
  }
}
