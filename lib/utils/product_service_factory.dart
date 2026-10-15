import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/repositories/category_repository.dart';
import 'package:ecommerce_api/repositories/product_repository.dart';
import 'package:ecommerce_api/services/product_service.dart';

ProductService createProductService() {
  final db = Database.db;

  final productRepository = ProductRepository(db);
  final categoryRepository = CategoryRepository(db);

  return ProductService(
    repository: productRepository,
    categoryRepository: categoryRepository,
  );
}
