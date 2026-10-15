import 'package:mongo_dart/mongo_dart.dart';

class Cart {
  final ObjectId id;
  final ObjectId userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromDocument(Map<String, dynamic> document) {
    return Cart(
      id: document['_id'] as ObjectId,
      userId: document['userId'] as ObjectId,
      status: document['status'] as String? ?? 'ACTIVE',
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
      'userId': userId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
