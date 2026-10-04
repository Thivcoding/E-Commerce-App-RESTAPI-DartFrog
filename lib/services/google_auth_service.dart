import 'package:jose_plus/jose.dart';

import '../config/env.dart';

class GoogleAuthService {
  static final Uri _jwksUri = Uri.parse(
    'https://www.googleapis.com/oauth2/v3/certs',
  );

  static final JsonWebKeyStore _keyStore = JsonWebKeyStore()
    ..addKeySetUrl(_jwksUri);

  Future<Map<String, dynamic>> verifyIdToken(
    String idToken,
  ) async {
    final token = idToken.trim();

    if (token.isEmpty) {
      throw Exception(
        'Google ID token is required',
      );
    }

    try {
      final jwt = await JsonWebToken.decodeAndVerify(
        token,
        _keyStore,
        allowedArguments: [
          'RS256',
        ],
      );

      final claims = jwt.claims.toJson();

      final issuer = claims['iss']?.toString();

      final audience = claims['aud']?.toString();

      final subject = claims['sub']?.toString();

      final email = claims['email']?.toString();

      final name = claims['name']?.toString();

      final emailVerified = claims['email_verified'] == true;

      if (issuer != 'https://accounts.google.com' &&
          issuer != 'accounts.google.com') {
        throw Exception(
          'Invalid Google token issuer',
        );
      }

      if (audience != Env.googleClientId) {
        throw Exception(
          'Invalid Google token audience',
        );
      }

      if (subject == null || subject.isEmpty) {
        throw Exception(
          'Google user ID is missing',
        );
      }

      if (email == null || email.isEmpty) {
        throw Exception(
          'Google email is missing',
        );
      }

      if (!emailVerified) {
        throw Exception(
          'Google email is not verified',
        );
      }

      return {
        'providerId': subject,
        'email': email.trim().toLowerCase(),
        'name': name?.trim().isNotEmpty == true
            ? name!.trim()
            : email.split('@').first,
        'emailVerified': emailVerified,
      };
    } catch (e) {
      if (e is Exception &&
          e.toString().contains(
            'Google',
          )) {
        rethrow;
      }

      throw Exception(
        'Invalid Google ID token',
      );
    }
  }
}
