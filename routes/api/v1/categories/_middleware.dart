import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/config/env.dart';

Handler middleware(
  Handler handler,
) {
  return (context) async {
    if (!Database.isConnected) {
      Env.load();
      await Database.connect();
    }

    return handler(context);
  };
}