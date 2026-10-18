import 'package:khqr_generator/khqr_generator.dart';

import '../config/env.dart';

class GeneratedBakongQr {
  final String qr;
  final String md5;
  final DateTime expiresAt;

  const GeneratedBakongQr({
    required this.qr,
    required this.md5,
    required this.expiresAt,
  });
}

class BakongQrService {
  GeneratedBakongQr generate({
    required String orderId,
    required double amount,
    required String currency,
  }) {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (Env.bakongAccountId.isEmpty ||
        Env.bakongMerchantName.isEmpty ||
        Env.bakongMerchantId.isEmpty ||
        Env.bakongAcquiringBank.isEmpty) {
      throw StateError('Bakong merchant configuration is missing');
    }

    final normalizedCurrency = currency.toUpperCase();

    final currencyCode = switch (normalizedCurrency) {
      'USD' => KHQRCurrency.usd.code,
      'KHR' => KHQRCurrency.khr.code,
      _ => throw ArgumentError('Unsupported currency'),
    };

    if (normalizedCurrency == 'KHR' && amount != amount.roundToDouble()) {
      throw ArgumentError('KHR amount must be a whole number');
    }

    final expiresAt = DateTime.now().add(
      const Duration(minutes: 15),
    );

    final merchantInfo = MerchantInfo(
      bakongAccountID: Env.bakongAccountId,
      merchantName: Env.bakongMerchantName,
      merchantCity: Env.bakongMerchantCity,
      merchantID: Env.bakongMerchantId,
      acquiringBank: Env.bakongAcquiringBank,
      amount: amount,
      currency: currencyCode,
      billNumber: orderId,
      purposeOfTransaction: 'E-commerce order payment',
      expirationTimestamp: expiresAt.millisecondsSinceEpoch,
    );

    final response = KHQRGenerator.generateMerchant(merchantInfo);

    if (response.status.code != 0 || response.data == null) {
      final message = response.status.message;

      throw Exception(
        message != null && message.isNotEmpty
            ? message
            : 'Failed to generate Bakong KHQR',
      );
    }

    final qr = response.data!.qr;
    final md5 = response.data!.md5;

    if (!KHQRGenerator.verify(qr).isValid) {
      throw Exception('Generated KHQR is invalid');
    }

    return GeneratedBakongQr(
      qr: qr,
      md5: md5.toLowerCase(),
      expiresAt: expiresAt,
    );
  }
}
