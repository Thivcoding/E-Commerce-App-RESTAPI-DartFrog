import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/controllers/auth_controller.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final repository = UserRepository(Database.db);
  final service = AuthService(repository);
  final controller = AuthController(service);

  return controller.register(context);
}