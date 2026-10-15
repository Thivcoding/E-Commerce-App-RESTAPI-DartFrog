import 'package:mongo_dart/mongo_dart.dart';

import '../models/product.dart';
import '../models/pagination_result.dart';
import '../models/product_query.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../dto/request/products/create_product_request.dart';
import '../dto/request/products/update_product_request.dart';
import '../dto/response/products/product_response.dart';

class ProductService {
  final ProductRepository repository;
  final CategoryRepository categoryRepository;

  ProductService({
    required this.repository,
    required this.categoryRepository,
  });

  Future<ProductResponse> create(
    CreateProductRequest request,
  ) async {
    final name = request.name.trim();
    final description = request.description.trim();

    _validateFields(
      name: name,
      description: description,
      price: request.price,
      stock: request.stock,
      images: request.images,
    );

    final categoryId = _parseObjectId(request.categoryId);
    final category = await categoryRepository.findById(categoryId);

    if (category == null) {
      throw Exception('Category not found');
    }

    if (!category.isActive) {
      throw Exception('Category is inactive');
    }

    final now = DateTime.now();

    final product = Product(
      name: name,
      description: description,
      price: request.price,
      stock: request.stock,
      categoryId: categoryId,
      images: request.images,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final created = await repository.create(product);

    return ProductResponse.fromModel(created);
  }

  Future<PaginationResult<ProductResponse>> findAll({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? search,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1
        ? 10
        : limit > 100
        ? 100
        : limit;

    ObjectId? parsedCategoryId;

    if (categoryId != null && categoryId.trim().isNotEmpty) {
      parsedCategoryId = _parseObjectId(categoryId.trim());

      final category = await categoryRepository.findById(
        parsedCategoryId,
      );

      if (category == null) {
        throw Exception('Category not found');
      }

      if (!category.isActive) {
        throw Exception('Category is inactive');
      }
    }

    final results = await Future.wait([
      repository.findPage(
        skip: (safePage - 1) * safeLimit,
        limit: safeLimit,
        categoryId: parsedCategoryId,
        search: search,
      ),
      repository.countProducts(
        categoryId: parsedCategoryId,
        search: search,
      ),
    ]);

    final products = results[0] as List<Product>;
    final total = results[1] as int;

    return PaginationResult<ProductResponse>(
      items: products.map(ProductResponse.fromModel).toList(),
      total: total,
      page: safePage,
      limit: safeLimit,
    );
  }

  Future<ProductResponse> findById(String id) async {
    final objectId = _parseObjectId(id);
    final product = await repository.findById(objectId);

    if (product == null || !product.isActive) {
      throw Exception('Product not found');
    }

    return ProductResponse.fromModel(product);
  }

  Future<ProductResponse> update(
    String id,
    UpdateProductRequest request,
  ) async {
    final objectId = _parseObjectId(id);
    final existing = await repository.findById(objectId);

    if (existing == null) {
      throw Exception('Product not found');
    }

    final name = request.name.trim();
    final description = request.description.trim();

    _validateFields(
      name: name,
      description: description,
      price: request.price,
      stock: request.stock,
      images: request.images,
    );

    final categoryId = _parseObjectId(request.categoryId);
    final category = await categoryRepository.findById(categoryId);

    if (category == null) {
      throw Exception('Category not found');
    }

    if (!category.isActive) {
      throw Exception('Category is inactive');
    }

    final updatedProduct = Product(
      id: objectId,
      name: name,
      description: description,
      price: request.price,
      stock: request.stock,
      categoryId: categoryId,
      images: request.images,
      isActive: request.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    final updated = await repository.update(
      objectId,
      updatedProduct,
    );

    if (updated == null) {
      throw Exception('Failed to update product');
    }

    return ProductResponse.fromModel(updated);
  }

  Future<void> delete(String id) async {
    final objectId = _parseObjectId(id);
    final existing = await repository.findById(objectId);

    if (existing == null) {
      throw Exception('Product not found');
    }

    final deleted = await repository.delete(objectId);

    if (!deleted) {
      throw Exception('Failed to delete product');
    }
  }

  ObjectId _parseObjectId(String id) {
    try {
      return ObjectId.parse(id);
    } catch (_) {
      throw Exception('Invalid ID format');
    }
  }

  void _validateFields({
    required String name,
    required String description,
    required double price,
    required int stock,
    required List<String> images,
  }) {
    if (name.isEmpty) {
      throw Exception('Product name is required');
    }

    if (name.length < 2) {
      throw Exception('Product name must be at least 2 characters');
    }

    if (description.isEmpty) {
      throw Exception('Product description is required');
    }

    if (price < 0) {
      throw Exception('Price must be zero or greater');
    }

    if (stock < 0) {
      throw Exception('Stock must be zero or greater');
    }

    if (images.any((image) => image.trim().isEmpty)) {
      throw Exception('Image URL cannot be empty');
    }
  }
}
