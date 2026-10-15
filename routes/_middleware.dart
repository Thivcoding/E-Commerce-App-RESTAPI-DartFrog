import 'package:dart_frog/dart_frog.dart';

import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/config/env.dart';

Handler middleware(Handler handler) {
  return (context) async {
    Env.load();

    if (!Database.isConnected) {
      await Database.connect();
    }

    return handler(context);
  };
}
