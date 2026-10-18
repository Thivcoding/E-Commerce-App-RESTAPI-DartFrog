import 'package:mongo_dart/mongo_dart.dart';

import '../models/category.dart';

class CategoryRepository {
  final DbCollection collection;

  CategoryRepository(Db db) : collection = db.collection('categories');

  Future<Category> create(
    Category category,
  ) async {
    final document = category.toDocument();

    final result = await collection.insertOne(
      document,
    );

    final insertedId = result.id;

    ObjectId objectId;

    if (insertedId is ObjectId) {
      objectId = insertedId;
    } else {
      objectId = ObjectId.parse(
        insertedId.toString(),
      );
    }

    return Category(
      id: objectId,
      name: category.name,
      description: category.description,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  Future<List<Category>> findAll() async {
    final documents = await collection
        .find(
          where.sortBy(
            'createdAt',
            descending: true,
          ),
        )
        .toList();

    return documents.map(_fromDocument).toList();
  }

  Future<List<Category>> findActive() async {
    final documents = await collection
        .find(
          where
              .eq('isActive', true)
              .sortBy(
                'name',
                descending: false,
              ),
        )
        .toList();

    return documents.map(_fromDocument).toList();
  }

  Future<Category?> findById(
    ObjectId id,
  ) async {
    final document = await collection.findOne(
      where.id(id),
    );

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<Category?> findByName(
    String name,
  ) async {
    final document = await collection.findOne(
      where.eq(
        'name',
        name,
      ),
    );

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<Category?> update(
    ObjectId id,
    Map<String, dynamic> data,
  ) async {
    await collection.updateOne(
      where.id(id),
      modify
        ..set(
          'name',
          data['name'],
        )
        ..set(
          'description',
          data['description'],
        )
        ..set(
          'isActive',
          data['isActive'],
        )
        ..set(
          'updatedAt',
          DateTime.now(),
        ),
    );

    return findById(id);
  }

  Future<bool> delete(
    ObjectId id,
  ) async {
    final result = await collection.deleteOne(
      where.id(id),
    );

    return result.nRemoved > 0;
  }

  Category _fromDocument(
    Map<String, dynamic> document,
  ) {
    return Category(
      id: _parseObjectId(
        document['_id'],
      ),
      name: document['name']?.toString() ?? '',
      description: document['description']?.toString() ?? '',
      isActive: document['isActive'] == true,
      createdAt: _parseDateTime(document['createdAt']),
      updatedAt: _parseDateTime(document['updatedAt']),
    );
  }

  ObjectId? _parseObjectId(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is ObjectId) {
      return value;
    }

    return ObjectId.parse(
      value.toString(),
    );
  }

  DateTime _parseDateTime(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(
      value.toString(),
    );
  }
}
