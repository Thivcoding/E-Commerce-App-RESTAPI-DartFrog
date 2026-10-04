import 'package:mongo_dart/mongo_dart.dart';

import '../dto/request/category/create_category_request.dart';
import '../dto/request/category/update_category_request.dart';
import '../dto/response/category/category_response.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryService {
  final CategoryRepository repository;

  CategoryService(
    this.repository,
  );

  // =====================================================
  // CREATE
  // =====================================================

  Future<CategoryResponse> create(
    CreateCategoryRequest request,
  ) async {
    final name = request.name.trim();
    final description = request.description.trim();

    if (name.isEmpty) {
      throw Exception(
        'Category name is required',
      );
    }

    if (name.length < 2) {
      throw Exception(
        'Category name must be at least 2 characters',
      );
    }

    final existing = await repository.findByName(name);

    if (existing != null) {
      throw Exception(
        'Category already exists',
      );
    }

    final now = DateTime.now();

    final category = Category(
      name: name,
      description: description,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final created = await repository.create(category);

    return CategoryResponse.fromModel(
      created,
    );
  }

  // =====================================================
  // GET ALL
  // =====================================================

  Future<List<CategoryResponse>> findAll() async {
    final categories = await repository.findAll();

    return categories
        .map(
          CategoryResponse.fromModel,
        )
        .toList();
  }

  // =====================================================
  // GET ACTIVE
  // =====================================================

  Future<List<CategoryResponse>> findActive() async {
    final categories = await repository.findActive();

    return categories
        .map(
          CategoryResponse.fromModel,
        )
        .toList();
  }

  // =====================================================
  // GET BY ID
  // =====================================================

  Future<CategoryResponse> findById(
    String id,
  ) async {
    final objectId = _parseObjectId(id);

    final category = await repository.findById(
      objectId,
    );

    if (category == null) {
      throw Exception(
        'Category not found',
      );
    }

    return CategoryResponse.fromModel(
      category,
    );
  }

  // =====================================================
  // UPDATE
  // =====================================================

  Future<CategoryResponse> update(
    String id,
    UpdateCategoryRequest request,
  ) async {
    final objectId = _parseObjectId(id);

    final existing = await repository.findById(
      objectId,
    );

    if (existing == null) {
      throw Exception(
        'Category not found',
      );
    }

    final name = request.name.trim();
    final description = request.description.trim();

    if (name.isEmpty) {
      throw Exception(
        'Category name is required',
      );
    }

    if (name.length < 2) {
      throw Exception(
        'Category name must be at least 2 characters',
      );
    }

    final categoryWithSameName = await repository.findByName(name);

    if (categoryWithSameName != null && categoryWithSameName.id != objectId) {
      throw Exception(
        'Category name already exists',
      );
    }

    final updated = await repository.update(
      objectId,
      {
        'name': name,
        'description': description,
        'isActive': request.isActive,
      },
    );

    if (updated == null) {
      throw Exception(
        'Failed to update category',
      );
    }

    return CategoryResponse.fromModel(
      updated,
    );
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> delete(
    String id,
  ) async {
    final objectId = _parseObjectId(id);

    final existing = await repository.findById(
      objectId,
    );

    if (existing == null) {
      throw Exception(
        'Category not found',
      );
    }

    final deleted = await repository.delete(
      objectId,
    );

    if (!deleted) {
      throw Exception(
        'Failed to delete category',
      );
    }
  }

  // =====================================================
  // PARSE OBJECT ID
  // =====================================================

  ObjectId _parseObjectId(
    String id,
  ) {
    try {
      return ObjectId.parse(id);
    } catch (_) {
      throw Exception(
        'Invalid category ID',
      );
    }
  }
}
