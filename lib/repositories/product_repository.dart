import 'package:mongo_dart/mongo_dart.dart';

import '../models/product.dart';

class ProductRepository {
  final DbCollection collection;

  ProductRepository(Db db) : collection = db.collection('products');

  Future<Product> create(Product product) async {
    final document = product.toDocument();
    final result = await collection.insertOne(document);
    final insertedId = result.id;

    if (insertedId == null) {
      throw Exception('Failed to create product');
    }

    final id = insertedId is ObjectId
        ? insertedId
        : ObjectId.parse(insertedId.toString());

    return Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      categoryId: product.categoryId,
      images: product.images,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Future<List<Product>> findAll() async {
    final documents = await collection
        .find(
          where.sortBy('createdAt', descending: true),
        )
        .toList();

    return documents.map(_fromDocument).toList();
  }

  Future<Product?> findById(ObjectId id) async {
    final document = await collection.findOne(where.id(id));

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<List<Product>> findByCategory(ObjectId categoryId) async {
    final documents = await collection
        .find(
          where
              .eq('categoryId', categoryId)
              .sortBy('createdAt', descending: true),
        )
        .toList();

    return documents.map(_fromDocument).toList();
  }

  Future<Product?> update(ObjectId id, Product product) async {
    await collection.updateOne(
      where.id(id),
      modify
        ..set('name', product.name)
        ..set('description', product.description)
        ..set('price', product.price)
        ..set('stock', product.stock)
        ..set('categoryId', product.categoryId)
        ..set('images', product.images)
        ..set('isActive', product.isActive)
        ..set('updatedAt', DateTime.now()),
    );

    return findById(id);
  }

  Future<bool> delete(ObjectId id) async {
    final result = await collection.deleteOne(where.id(id));
    return result.nRemoved > 0;
  }

  SelectorBuilder _buildProductSelector({
    ObjectId? categoryId,
    String? search,
  }) {
    final selector = SelectorBuilder()..eq('isActive', true);

    if (categoryId != null) {
      selector.eq('categoryId', categoryId);
    }

    if (search != null && search.trim().isNotEmpty) {
      selector.match(
        'name',
        RegExp.escape(search.trim()),
        caseInsensitive: true,
      );
    }

    return selector;
  }

  Future<List<Product>> findPage({
    required int skip,
    required int limit,
    ObjectId? categoryId,
    String? search,
  }) async {
    final selector = _buildProductSelector(
      categoryId: categoryId,
      search: search,
    );

    final documents = await collection
        .find(
          selector
              .sortBy('createdAt', descending: true)
              .skip(skip)
              .limit(limit),
        )
        .toList();

    return documents.map(_fromDocument).toList();
  }

  Future<int> countProducts({
    ObjectId? categoryId,
    String? search,
  }) async {
    final selector = _buildProductSelector(
      categoryId: categoryId,
      search: search,
    );

    return collection.count(selector);
  }

  Product _fromDocument(Map<String, dynamic> document) {
    return Product(
      id: _parseObjectId(document['_id']),
      name: document['name']?.toString() ?? '',
      description: document['description']?.toString() ?? '',
      price: _parseDouble(document['price']),
      stock: _parseInt(document['stock']),
      categoryId: _parseObjectId(document['categoryId']),
      images: document['images'] is List
          ? (document['images'] as List).map((item) => item.toString()).toList()
          : <String>[],
      isActive: document['isActive'] == true,
      createdAt: _parseDateTime(document['createdAt']),
      updatedAt: _parseDateTime(document['updatedAt']),
    );
  }

  ObjectId _parseObjectId(dynamic value) {
    if (value is ObjectId) {
      return value;
    }

    if (value == null) {
      throw Exception('MongoDB ObjectId is missing');
    }

    return ObjectId.parse(value.toString());
  }

  double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.parse(value.toString());
  }

  int _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.parse(value.toString());
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value.toString());
  }
}
