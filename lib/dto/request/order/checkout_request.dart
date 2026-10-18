class CheckoutRequest {
  final String fullName;
  final String phoneNumber;
  final String shippingAddress;
  final String paymentMethod;

  CheckoutRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) {
    final fullName = json['fullName'];
    final phoneNumber = json['phoneNumber'];
    final shippingAddress = json['shippingAddress'];
    final paymentMethod = json['paymentMethod'];

    if (fullName is! String || fullName.trim().isEmpty) {
      throw FormatException('Full name is required');
    }

    if (phoneNumber is! String || phoneNumber.trim().isEmpty) {
      throw FormatException('Phone number is required');
    }

    if (!RegExp(r'^[0-9+()\-\s]{8,20}$').hasMatch(phoneNumber.trim())) {
      throw FormatException('Invalid phone number');
    }

    if (shippingAddress is! String || shippingAddress.trim().isEmpty) {
      throw FormatException('Shipping address is required');
    }

    if (paymentMethod is! String ||
        !['CASH', 'CARD', 'BAKONG'].contains(
          paymentMethod.trim().toUpperCase(),
        )) {
      throw FormatException('Invalid payment method');
    }

    return CheckoutRequest(
      fullName: fullName.trim(),
      phoneNumber: phoneNumber.trim(),
      shippingAddress: shippingAddress.trim(),
      paymentMethod: paymentMethod.trim().toUpperCase(),
    );
  }
}
