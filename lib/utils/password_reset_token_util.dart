import 'dart:math';

class PasswordResetTokenUtil {
  static final Random _random = Random.secure();

  static String generate() {
    final values = List<int>.generate(
      32,
      (_) => _random.nextInt(256),
    );

    return values
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}