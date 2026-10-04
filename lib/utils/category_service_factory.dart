import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/repositories/category_repository.dart';
import 'package:ecommerce_api/services/category_service.dart';

CategoryService createCategoryService() {
  final db = Database.db;

  final repository = CategoryRepository(db);

  return CategoryService(
    repository,
  );
}
