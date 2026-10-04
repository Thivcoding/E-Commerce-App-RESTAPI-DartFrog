import 'package:dart_frog/dart_frog.dart';

import '../dto/request/category/create_category_request.dart';
import '../dto/request/category/update_category_request.dart';
import '../services/category_service.dart';
import '../utils/response_util.dart';

class CategoryController {
  final CategoryService service;

  CategoryController(
    this.service,
  );

  // =====================================================
  // CREATE
  // =====================================================

  Future<Response> create(
    RequestContext context,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = CreateCategoryRequest.fromJson(
        Map<String, dynamic>.from(
          body,
        ),
      );

      final result = await service.create(
        request,
      );

      return ResponseUtil.success(
        message: 'Category created successfully',
        data: result.toJson(),
        statusCode: 201,
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 400,
      );
    }
  }

  // =====================================================
  // GET ALL
  // =====================================================

  Future<Response> findAll(
    RequestContext context,
  ) async {
    try {
      final categories = await service.findAll();

      return ResponseUtil.success(
        message: 'Categories retrieved successfully',
        data: categories
            .map(
              (category) => category.toJson(),
            )
            .toList(),
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 500,
      );
    }
  }

  // =====================================================
  // GET ACTIVE
  // =====================================================

  Future<Response> findActive(
    RequestContext context,
  ) async {
    try {
      final categories = await service.findActive();

      return ResponseUtil.success(
        message: 'Active categories retrieved successfully',
        data: categories
            .map(
              (category) => category.toJson(),
            )
            .toList(),
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 500,
      );
    }
  }

  // =====================================================
  // GET BY ID
  // =====================================================

  Future<Response> findById(
    RequestContext context,
    String id,
  ) async {
    try {
      final result = await service.findById(id);

      return ResponseUtil.success(
        message: 'Category retrieved successfully',
        data: result.toJson(),
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 404,
      );
    }
  }

  // =====================================================
  // UPDATE
  // =====================================================

  Future<Response> update(
    RequestContext context,
    String id,
  ) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = UpdateCategoryRequest.fromJson(
        Map<String, dynamic>.from(
          body,
        ),
      );

      final result = await service.update(
        id,
        request,
      );

      return ResponseUtil.success(
        message: 'Category updated successfully',
        data: result.toJson(),
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 400,
      );
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<Response> delete(
    RequestContext context,
    String id,
  ) async {
    try {
      await service.delete(id);

      return ResponseUtil.success(
        message: 'Category deleted successfully',
      );
    } catch (e) {
      return ResponseUtil.error(
        message: _cleanError(e),
        statusCode: 404,
      );
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  String _cleanError(
    Object error,
  ) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }
}
