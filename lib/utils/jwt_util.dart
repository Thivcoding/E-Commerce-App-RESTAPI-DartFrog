import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../config/env.dart';

class JwtUtil {
  static String generateAccessToken({
    required String userId,
    required String email,
    required String role,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'role': role,
        'type': 'access',
      },
      issuer: 'ecommerce-api',
    );

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(
        seconds: Env.jwtAccessExpires,
      ),
    );
  }

  static String generateRefreshToken({
    required String userId,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'type': 'refresh',
      },
      issuer: 'ecommerce-api',
    );

    return jwt.sign(
      SecretKey(Env.jwtSecret),
      expiresIn: Duration(
        seconds: Env.jwtRefreshExpires,
      ),
    );
  }

  static Map<String, dynamic> verify(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(Env.jwtSecret),
      issuer: 'ecommerce-api',
    );

    return Map<String, dynamic>.from(jwt.payload as Map);
  }
}
