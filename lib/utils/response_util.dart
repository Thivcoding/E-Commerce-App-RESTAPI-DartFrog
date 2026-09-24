import 'package:dart_frog/dart_frog.dart';

class ResponseUtil {
  static Response success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
      },
    );
  }

  static Response error({
    String message = 'Something went wrong',
    int statusCode = 500,
    dynamic data,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'message': message,
        'data': data,
      },
    );
  }
}
