import 'package:dotenv/dotenv.dart';

class Env {
  static late final String mongoUri;
  static late final String mongoDatabase;
  static late final String jwtSecret;
  static late final int jwtAccessExpires;
  static late final int jwtRefreshExpires;
  static late String smtpHost;
  static late int smtpPort;
  static late String smtpUsername;
  static late String smtpPassword;

  static late String smtpFromEmail;
  static late String smtpFromName;

  static late String appBaseUrl;
  static late int emailVerificationExpiresMinutes;

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

    smtpHost = env['SMTP_HOST'] ?? '';
    smtpPort = int.parse(
      env['SMTP_PORT'] ?? '587',
    );

    smtpUsername = env['SMTP_USERNAME'] ?? '';
    smtpPassword = env['SMTP_PASSWORD'] ?? '';

    smtpFromEmail =
        env['SMTP_FROM_EMAIL'] ?? '';

    smtpFromName =
        env['SMTP_FROM_NAME'] ?? 'Ecommerce API';

    appBaseUrl =
        env['APP_BASE_URL'] ?? 'http://localhost:8080';

    emailVerificationExpiresMinutes = int.parse(
      env['EMAIL_VERIFICATION_EXPIRES_MINUTES'] ?? '15',
    );

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
