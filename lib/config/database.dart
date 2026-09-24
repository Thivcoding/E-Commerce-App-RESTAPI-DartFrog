import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';

class Database {
  static Db? _db;

  static bool get isConnected {
    return _db != null && _db!.isConnected;
  }

  static Future<void> connect() async {
    if (isConnected) {
      return;
    }

    final uri = _buildMongoUri();

    print('Connecting to MongoDB...');
    print('Database: ${Env.mongoDatabase}');

    try {
      final database = await Db.create(uri);

      await database.open();

      _db = database;

      print('MongoDB connected successfully');
    } catch (e) {
      print('MongoDB connection failed: $e');
      rethrow;
    }
  }

  static String _buildMongoUri() {
    final uri = Env.mongoUri.trim();
    final databaseName = Env.mongoDatabase.trim();

    if (uri.isEmpty) {
      throw Exception('MONGO_URI is required');
    }

    if (databaseName.isEmpty) {
      throw Exception('MONGO_DATABASE is required');
    }

    final questionMarkIndex = uri.indexOf('?');

    if (questionMarkIndex == -1) {
      if (uri.endsWith('/')) {
        return '$uri$databaseName';
      }

      return '$uri/$databaseName';
    }

    final baseUri = uri.substring(0, questionMarkIndex);
    final query = uri.substring(questionMarkIndex);

    final cleanBaseUri = baseUri.endsWith('/')
        ? baseUri.substring(0, baseUri.length - 1)
        : baseUri;

    return '$cleanBaseUri/$databaseName$query';
  }

  static Db get db {
    final database = _db;

    if (database == null || !database.isConnected) {
      throw Exception('Database is not connected');
    }

    return database;
  }

  static Future<void> close() async {
    final database = _db;

    if (database != null && database.isConnected) {
      await database.close();
    }

    _db = null;
  }
}
