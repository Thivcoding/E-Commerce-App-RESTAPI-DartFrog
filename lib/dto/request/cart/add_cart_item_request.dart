import 'package:mongo_dart/mongo_dart.dart';

class AddCartItemRequest {
  final ObjectId productId;
  final int quantity;

  AddCartItemRequest({
    required this.productId,
    required this.quantity,
  });

  factory AddCartItemRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    final productIdValue = json['productId'];
    final quantityValue = json['quantity'];

    if (productIdValue is! String || !ObjectId.isValidHexId(productIdValue)) {
      throw FormatException('Invalid productId');
    }

    if (quantityValue is! int || quantityValue < 1) {
      throw FormatException('Quantity must be a positive integer');
    }

    return AddCartItemRequest(
      productId: ObjectId.fromHexString(productIdValue),
      quantity: quantityValue,
    );
  }
}
