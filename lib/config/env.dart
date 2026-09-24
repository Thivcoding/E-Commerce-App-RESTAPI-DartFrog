import 'package:dotenv/dotenv.dart';

class Env {
  static late final String mongoUri;
  static late final String mongoDatabase;
  static late final String jwtSecret;
  static late final int jwtAccessExpires;
  static late final int jwtRefreshExpires;

  static void load() {
    final env = DotEnv(includePlatformEnvironment: true)..load();

    mongoUri = env['MONGO_URI'] ?? '';
    mongoDatabase = env['MONGO_DATABASE'] ?? '';
    jwtSecret = env['JWT_SECRET'] ?? '';

    jwtAccessExpires =
        int.tryParse(
          env['JWT_ACCESS_EXPIRES'] ?? '',
        ) ??
        3600;

    jwtRefreshExpires =
        int.tryParse(
          env['JWT_REFRESH_EXPIRES'] ?? '',
        ) ??
        604800;

    if (mongoUri.isEmpty) {
      throw Exception('MONGO_URI is required');
    }

    if (mongoDatabase.isEmpty) {
      throw Exception('MONGO_DATABASE is required');
    }

    if (jwtSecret.isEmpty) {
      throw Exception('JWT_SECRET is required');
    }
  }
}
