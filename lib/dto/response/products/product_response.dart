import '../../../models/product.dart';

class ProductResponse {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductResponse({
    required this.id,
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

  factory ProductResponse.fromModel(
    Product product,
  ) {
    return ProductResponse(
      id: product.id?.toHexString() ?? '',
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      categoryId: product.categoryId.toHexString(),
      images: product.images,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'images': images,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
