import 'package:ecommerce_api/config/database.dart';
import 'package:ecommerce_api/config/env.dart';

Future<void> main() async {
  try {
    Env.load();

    await Database.connect();

    print('DATABASE TEST SUCCESS');
  } catch (e) {
    print('DATABASE TEST FAILED');
    print(e);
  } finally {
    await Database.close();
  }
}
