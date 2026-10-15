import '../config/database.dart';
import '../repositories/cart_item_repository.dart';
import '../repositories/cart_repository.dart';
import '../services/cart_service.dart';

CartService createCartService() {
  final db = Database.db;

  return CartService(
    db: db,
    cartRepository: CartRepository(db),
    itemRepository: CartItemRepository(db),
  );
}
