import 'package:mongo_dart/mongo_dart.dart';

import '../models/user.dart';

class UserRepository {
  final Db db;

  UserRepository(this.db);

  DbCollection get collection {
    return db.collection('users');
  }

  Future<User?> findByEmail(String email) async {
    final document = await collection.findOne(
      where.eq(
        'email',
        email.trim().toLowerCase(),
      ),
    );

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<User?> findById(String id) async {
    final objectId = ObjectId.parse(id);

    final document = await collection.findOne(
      where.eq('_id', objectId),
    );

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<User> create(User user) async {
    final document = user.toDocument();

    final result = await collection.insertOne(document);

    final insertedId = result.id;

    if (insertedId is! ObjectId) {
      throw Exception('Failed to create user');
    }

    final createdUser = await collection.findOne(
      where.eq('_id', insertedId),
    );

    if (createdUser == null) {
      throw Exception('Failed to retrieve created user');
    }

    return _fromDocument(createdUser);
  }

  Future<User?> updateById(
    String id,
    Map<String, dynamic> data,
  ) async {
    final objectId = ObjectId.parse(id);

    final updateData = Map<String, dynamic>.from(data);

    updateData['updatedAt'] = DateTime.now();

    await collection.updateOne(
      where.eq('_id', objectId),
      modify.set('updatedAt', updateData['updatedAt']),
    );

    for (final entry in updateData.entries) {
      if (entry.key == 'updatedAt') {
        continue;
      }

      await collection.updateOne(
        where.eq('_id', objectId),
        modify.set(entry.key, entry.value),
      );
    }

    final document = await collection.findOne(
      where.eq('_id', objectId),
    );

    if (document == null) {
      return null;
    }

    return _fromDocument(document);
  }

  Future<bool> deleteById(String id) async {
    final objectId = ObjectId.parse(id);

    final existing = await collection.findOne(
      where.eq('_id', objectId),
    );

    if (existing == null) {
      return false;
    }

    await collection.deleteOne(
      where.eq('_id', objectId),
    );

    return true;
  }

  Future<bool> existsByEmail(String email) async {
    final document = await collection.findOne(
      where.eq(
        'email',
        email.trim().toLowerCase(),
      ),
    );

    return document != null;
  }

  User _fromDocument(Map<String, dynamic> document) {
    final rawId = document['_id'];

    ObjectId? id;

    if (rawId is ObjectId) {
      id = rawId;
    } else if (rawId != null) {
      id = ObjectId.parse(
        rawId.toString(),
      );
    }

    return User(
      id: id,
      name: document['name']?.toString() ?? '',
      email: document['email']?.toString() ?? '',
      password: document['password']?.toString() ?? '',
      role: document['role']?.toString() ?? 'USER',

      isActive: document['isActive'] == true,

      isEmailVerified:
          document['isEmailVerified'] == true,

      emailVerifiedAt: document['emailVerifiedAt'] == null
          ? null
          : _parseDateTime(document['emailVerifiedAt']),

      createdAt: _parseDateTime(document['createdAt']),
      updatedAt: _parseDateTime(document['updatedAt']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value != null) {
      return DateTime.tryParse(
            value.toString(),
          ) ??
          DateTime.now();
    }

    return DateTime.now();
  }
}
