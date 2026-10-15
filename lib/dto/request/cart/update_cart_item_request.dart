class UpdateCartItemRequest {
  final int quantity;

  UpdateCartItemRequest({
    required this.quantity,
  });

  factory UpdateCartItemRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    final quantityValue = json['quantity'];

    if (quantityValue is! int || quantityValue < 1) {
      throw FormatException('Quantity must be a positive integer');
    }

    return UpdateCartItemRequest(
      quantity: quantityValue,
    );
  }
}
