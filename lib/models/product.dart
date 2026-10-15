import 'package:mongo_dart/mongo_dart.dart';

class Product {
  final ObjectId? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final ObjectId categoryId;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
