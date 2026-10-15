class UpdateProductRequest {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> images;
  final bool isActive;

  UpdateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
    required this.isActive,
  });

  factory UpdateProductRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdateProductRequest(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parsePrice(json['price']),
      stock: _parseStock(json['stock']),
      categoryId: json['categoryId']?.toString() ?? '',
      images: json['images'] is List
          ? (json['images'] as List).map((item) => item.toString()).toList()
          : <String>[],
      isActive: json['isActive'] == true,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? -1;
  }

  static int _parseStock(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num && value == value.toInt()) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? -1;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'images': images,
      'isActive': isActive,
    };
  }
}
