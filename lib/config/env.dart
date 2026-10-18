import 'package:dotenv/dotenv.dart';

class Env {
  static bool _loaded = false;

  static late final String mongoUri;
  static late final String mongoDatabase;

  static late final String jwtSecret;
  static late final int jwtAccessExpires;
  static late final int jwtRefreshExpires;

  static late final String smtpHost;
  static late final int smtpPort;
  static late final String smtpUsername;
  static late final String smtpPassword;

  static late final String smtpFromEmail;
  static late final String smtpFromName;

  static late final String appBaseUrl;
  static late final int emailVerificationExpiresMinutes;

  static late final String googleClientId;

  static late String bakongToken;
  static late String bakongAccountId;
  static late String bakongBaseUrl;
  static late String bakongMerchantName;
  static late String bakongMerchantId;
  static late String bakongAcquiringBank;
  static late String bakongMerchantCity;

  static void load() {
    if (_loaded) {
      return;
    }

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

    smtpPort =
        int.tryParse(
          env['SMTP_PORT'] ?? '587',
        ) ??
        587;

    smtpUsername = env['SMTP_USERNAME'] ?? '';

    smtpPassword = env['SMTP_PASSWORD'] ?? '';

    smtpFromEmail = env['SMTP_FROM_EMAIL'] ?? '';

    smtpFromName = env['SMTP_FROM_NAME'] ?? 'Ecommerce API';

    appBaseUrl = env['APP_BASE_URL'] ?? 'http://localhost:8080';

    emailVerificationExpiresMinutes =
        int.tryParse(
          env['EMAIL_VERIFICATION_EXPIRES_MINUTES'] ?? '15',
        ) ??
        15;

    googleClientId = env['GOOGLE_CLIENT_ID'] ?? '';

    bakongToken = env['BAKONG_TOKEN'] ?? '';
    bakongAccountId = env['BAKONG_ACCOUNT_ID'] ?? '';
    bakongBaseUrl = env['BAKONG_BASE_URL'] ?? 'https://api-bakong.nbc.gov.kh';
    bakongMerchantName = env['BAKONG_MERCHANT_NAME'] ?? '';
    bakongMerchantId = env['BAKONG_MERCHANT_ID'] ?? '';
    bakongAcquiringBank = env['BAKONG_ACQUIRING_BANK'] ?? '';
    bakongMerchantCity = env['BAKONG_MERCHANT_CITY'] ?? 'Phnom Penh';

    if (mongoUri.isEmpty) {
      throw Exception(
        'MONGO_URI is required',
      );
    }

    if (mongoDatabase.isEmpty) {
      throw Exception(
        'MONGO_DATABASE is required',
      );
    }

    if (jwtSecret.isEmpty) {
      throw Exception(
        'JWT_SECRET is required',
      );
    }

    if (googleClientId.isEmpty) {
      throw Exception(
        'GOOGLE_CLIENT_ID is required',
      );
    }

    _loaded = true;
  }
}
