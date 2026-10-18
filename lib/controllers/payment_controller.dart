import 'package:mongo_dart/mongo_dart.dart';

import '../config/env.dart';
import '../repositories/payment_repository.dart';
import '../services/bakong_qr_service.dart';
import '../services/bakong_service.dart';

class PaymentController {
  final Db db;
  late final PaymentRepository paymentRepository;
  late final BakongService bakongService;
  late final BakongQrService bakongQrService;

  PaymentController({required this.db}) {
    paymentRepository = PaymentRepository(db);
    bakongService = BakongService(
      token: Env.bakongToken,
      baseUrl: Env.bakongBaseUrl,
    );
    bakongQrService = BakongQrService();
  }

  DbCollection get orders => db.collection('orders');

  Future<Map<String, dynamic>> createKhqrPayment({
    required ObjectId userId,
    required String orderId,
  }) async {
    if (!ObjectId.isValidHexId(orderId)) {
      throw FormatException('Invalid order ID');
    }

    if (Env.bakongToken.isEmpty || Env.bakongAccountId.isEmpty) {
      throw StateError('Bakong configuration is missing');
    }

    final parsedOrderId = ObjectId.fromHexString(orderId);

    final order = await orders.findOne(
      where.eq('_id', parsedOrderId).eq('userId', userId),
    );

    if (order == null) {
      throw Exception('Order not found');
    }

    if (order['paymentMethod'] != 'BAKONG') {
      throw Exception('Order payment method is not Bakong');
    }

    if (order['status'] != 'PENDING') {
      throw Exception('Order is not pending');
    }

    if (order['paymentStatus'] == 'PAID') {
      throw Exception('Order has already been paid');
    }

    final existing = await paymentRepository.findPendingByOrderId(
      parsedOrderId,
    );

    if (existing != null) {
      final expiresAt = existing['expiresAt'] as DateTime;

      if (DateTime.now().isBefore(expiresAt)) {
        return _paymentResponse(existing);
      }

      await paymentRepository.updateStatus(
        paymentId: existing['_id'] as ObjectId,
        status: 'EXPIRED',
      );
    }

    final amount = (order['totalAmount'] as num).toDouble();
    final currency = (order['currency'] as String).toUpperCase();

    final generatedQr = bakongQrService.generate(
      orderId: orderId,
      amount: amount,
      currency: currency,
    );

    final now = DateTime.now();
    final paymentId = ObjectId();

    final payment = <String, dynamic>{
      '_id': paymentId,
      'orderId': parsedOrderId,
      'userId': userId,
      'provider': 'BAKONG',
      'method': 'KHQR',
      'qr': generatedQr.qr,
      'md5': generatedQr.md5.toLowerCase(),
      'status': 'PENDING',
      'amount': amount,
      'currency': currency,
      'merchantAccountId': Env.bakongAccountId,
      'transactionHash': null,
      'createdAt': now,
      'updatedAt': now,
      'expiresAt': generatedQr.expiresAt,
    };

    await paymentRepository.create(payment);

    return _paymentResponse(payment);
  }

  Map<String, dynamic> _paymentResponse(
    Map<String, dynamic> payment,
  ) {
    return {
      'paymentId': (payment['_id'] as ObjectId).toHexString(),
      'orderId': (payment['orderId'] as ObjectId).toHexString(),
      'qr': payment['qr'],
      'amount': payment['amount'],
      'currency': payment['currency'],
      'status': payment['status'],
      'expiresAt': (payment['expiresAt'] as DateTime).toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> verifyPayment({
    required ObjectId userId,
    required String paymentId,
  }) async {
    if (!ObjectId.isValidHexId(paymentId)) {
      throw FormatException('Invalid payment ID');
    }

    final parsedPaymentId = ObjectId.fromHexString(paymentId);

    final payment = await paymentRepository.findByIdAndUserId(
      paymentId: parsedPaymentId,
      userId: userId,
    );

    if (payment == null) {
      throw Exception('Payment not found');
    }

    if (payment['status'] == 'PAID') {
      return {
        'paymentId': paymentId,
        'status': 'PAID',
        'transactionHash': payment['transactionHash'],
      };
    }

    if (payment['status'] != 'PENDING') {
      return {
        'paymentId': paymentId,
        'status': payment['status'],
      };
    }

    final expiresAt = payment['expiresAt'] as DateTime;

    if (!DateTime.now().isBefore(expiresAt)) {
      await paymentRepository.updateStatus(
        paymentId: parsedPaymentId,
        status: 'EXPIRED',
      );

      return {
        'paymentId': paymentId,
        'status': 'EXPIRED',
      };
    }

    final result = await bakongService.checkTransactionByMd5(
      payment['md5'] as String,
    );

    if (result['responseCode'] != 0) {
      return {
        'paymentId': paymentId,
        'status': 'PENDING',
        'message': 'Payment has not been confirmed',
      };
    }

    final rawData = result['data'];

    if (rawData is! Map) {
      throw Exception('Invalid transaction data');
    }

    final data = Map<String, dynamic>.from(rawData);
    final transactionHash = data['hash']?.toString();
    final receivedAmount = double.tryParse(
      data['amount']?.toString() ?? '',
    );
    final receivedCurrency = data['currency']?.toString().toUpperCase();
    final receivedAccount = data['toAccountId']?.toString();

    final expectedAmount = (payment['amount'] as num).toDouble();
    final expectedCurrency = (payment['currency'] as String).toUpperCase();
    final expectedAccount = payment['merchantAccountId'] as String;

    if (transactionHash == null || transactionHash.isEmpty) {
      throw Exception('Transaction hash is missing');
    }

    if (receivedAmount == null ||
        (receivedAmount - expectedAmount).abs() > 0.000001 ||
        receivedCurrency != expectedCurrency ||
        receivedAccount != expectedAccount) {
      throw Exception(
        'Payment amount, currency or merchant does not match',
      );
    }

    final existingTransaction = await paymentRepository.findByTransactionHash(
      transactionHash,
    );

    if (existingTransaction != null &&
        existingTransaction['_id'] != parsedPaymentId) {
      throw Exception('Transaction has already been used');
    }

    final orderId = payment['orderId'] as ObjectId;

    final order = await orders.findOne(
      where.eq('_id', orderId).eq('userId', userId),
    );

    if (order == null) {
      throw Exception('Order not found');
    }

    if (order['paymentStatus'] != 'UNPAID') {
      if (order['paymentStatus'] == 'PAID') {
        throw Exception(
          'Order is already paid; payment requires reconciliation',
        );
      }

      throw Exception('Order is not eligible for payment');
    }

    final claimed = await paymentRepository.claimAsPaid(
      paymentId: parsedPaymentId,
      transactionHash: transactionHash,
    );

    if (!claimed) {
      final latest = await paymentRepository.findByIdAndUserId(
        paymentId: parsedPaymentId,
        userId: userId,
      );

      if (latest?['status'] == 'PAID') {
        return {
          'paymentId': paymentId,
          'status': 'PAID',
          'transactionHash': latest?['transactionHash'],
        };
      }

      throw Exception('Payment status changed; please retry');
    }

    final orderUpdate = await orders.updateOne(
      where
          .eq('_id', orderId)
          .eq('userId', userId)
          .eq('status', 'PENDING')
          .eq('paymentStatus', 'UNPAID'),
      modify.set('paymentStatus', 'PAID').set('updatedAt', DateTime.now()),
    );

    if (orderUpdate.nMatched == 0) {
      throw Exception(
        'Payment was verified but order update failed; reconciliation is required',
      );
    }

    return {
      'paymentId': paymentId,
      'orderId': orderId.toHexString(),
      'status': 'PAID',
      'transactionHash': transactionHash,
      'amount': receivedAmount,
      'currency': receivedCurrency,
    };
  }
}
