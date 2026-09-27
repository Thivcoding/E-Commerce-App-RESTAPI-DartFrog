import 'dart:convert';

import 'package:crypto/crypto.dart';

class TokenHashUtil {
  static String hash(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}