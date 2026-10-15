import 'package:mongo_dart/mongo_dart.dart';

import 'env.dart';

class Database {
  static Db? _db;
  static Future<Db>? _connecting;

  static bool get isConnected => _db?.isConnected ?? false;

  /// Reuse the existing connection.
  /// Concurrent requests share the same connection attempt.
  static Future<void> connect() async {
    if (isConnected) {
      return;
    }

    final existingConnection = _connecting;

    if (existingConnection != null) {
      await existingConnection;
      return;
    }

    final connectionFuture = _doConnect();
    _connecting = connectionFuture;

    try {
      final database = await connectionFuture;
      _db = database;
    } finally {
      if (identical(_connecting, connectionFuture)) {
        _connecting = null;
      }
    }
  }

  static Future<Db> _doConnect() async {
    final uri = _buildMongoUri();

    print('Connecting to MongoDB...');
    print('Database: ${Env.mongoDatabase}');

    final database = await Db.create(uri);

    try {
      await database.open();
      print('MongoDB connected successfully');
      return database;
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  static String _buildMongoUri() {
    final uri = Env.mongoUri.trim();
    final databaseName = Env.mongoDatabase.trim();

    if (uri.isEmpty || databaseName.isEmpty) {
      throw Exception('MongoDB configuration is missing');
    }

    final questionMarkIndex = uri.indexOf('?');

    final baseUri = questionMarkIndex == -1
        ? uri
        : uri.substring(0, questionMarkIndex);

    final existingQuery = questionMarkIndex == -1
        ? ''
        : uri.substring(questionMarkIndex + 1);

    final cleanBaseUri = baseUri.endsWith('/')
        ? baseUri.substring(0, baseUri.length - 1)
        : baseUri;

    final queryParams = <String>[
      if (existingQuery.isNotEmpty) existingQuery,
    ];

    final hasSafeAtlas = existingQuery
        .split('&')
        .any((param) => param.split('=').first == 'safeAtlas');

    if (!hasSafeAtlas) {
      queryParams.add('safeAtlas=true');
    }

    return '$cleanBaseUri/$databaseName?${queryParams.join('&')}';
  }

  static Db get db {
    final database = _db;

    if (database == null || !database.isConnected) {
      throw Exception(
        'Database is not connected. Call Database.connect() first.',
      );
    }

    return database;
  }

  static Future<void> close() async {
    final database = _db;

    _db = null;

    if (database != null && database.isConnected) {
      await database.close();
    }
  }
}
