import 'dart:math';

class OtpUtil {
  static final Random _random = Random.secure();

  static String generate6DigitOtp() {
    final otp = _random.nextInt(1000000);

    return otp.toString().padLeft(6, '0');
  }
}