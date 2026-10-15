import 'package:dart_frog/dart_frog.dart';

import '../dto/request/products/create_product_request.dart';
import '../dto/request/products/update_product_request.dart';
import '../models/product_query.dart';
import '../services/product_service.dart';
import '../utils/response_util.dart';

class ProductController {
  final ProductService service;

  ProductController(this.service);

  Future<Response> create(RequestContext context) async {
    try {
      final body = await context.request.json();

      if (body is! Map) {
        return ResponseUtil.error(
          message: 'Invalid request body',
          statusCode: 400,
        );
      }

      final request = CreateProductRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      final result = await service.create(request);

      return ResponseUtil.success(
        message: 'Product created successfully',
        data: result.toJson(),
        statusCode: 201,
      );
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<Response> findAll(RequestContext context) async {
    try {
      final query = ProductQuery.fromQueryParameters(
        context.request.uri.queryParameters,
      );

      final result = await service.findAll(
        page: query.page,
        limit: query.limit,
        categoryId: query.categoryId,
        search: query.search,
      );

      return ResponseUtil.success(
        message: 'Products retrieved successfully',
        data: result.toJson(
          (product) => product.toJson(),
        ),
      );
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<Response> findById(
    RequestContext context,
    String id,
  ) async {
    try {
      final product = await service.findById(id);

      return ResponseUtil.success(
        message: 'Product retrieved successfully',
        data: product.toJson(),
      );
    } catch (error) {
      return _handleError(error);
    }
  }

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

      final request = UpdateProductRequest.fromJson(
        Map<String, dynamic>.from(body),
      );

      final product = await service.update(id, request);

      return ResponseUtil.success(
        message: 'Product updated successfully',
        data: product.toJson(),
      );
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<Response> delete(
    RequestContext context,
    String id,
  ) async {
    try {
      await service.delete(id);

      return ResponseUtil.success(
        message: 'Product deleted successfully',
      );
    } catch (error) {
      return _handleError(error);
    }
  }

  Response _handleError(Object error) {
    final message = error.toString().replaceFirst(
      'Exception: ',
      '',
    );

    final statusCode = switch (message) {
      'Product not found' => 404,
      'Category not found' => 400,
      'Category is inactive' => 400,
      'Invalid ID format' => 400,
      'Failed to create product' => 500,
      'Failed to update product' => 500,
      'Failed to delete product' => 500,
      _ => 400,
    };

    return ResponseUtil.error(
      message: message,
      statusCode: statusCode,
    );
  }
}
