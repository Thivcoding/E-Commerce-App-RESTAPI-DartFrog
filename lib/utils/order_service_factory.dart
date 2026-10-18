import '../config/database.dart';
import '../repositories/cart_item_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_item_repository.dart';
import '../repositories/order_repository.dart';
import '../services/order_service.dart';

OrderService createOrderService() {
  final db = Database.db;

  return OrderService(
    db: db,
    cartRepository: CartRepository(db),
    cartItemRepository: CartItemRepository(db),
    orderRepository: OrderRepository(db),
    orderItemRepository: OrderItemRepository(db),
  );
}
