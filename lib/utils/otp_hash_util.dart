import 'dart:convert';

import 'package:crypto/crypto.dart';

class OtpHashUtil {
  static String hash(String otp) {
    final bytes = utf8.encode(otp);

    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}