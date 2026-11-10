import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/services/qr_image_service.dart';

final qrImageService = QrImageService();

Future<Response> onRequest(RequestContext context) async {
  try {
    final body = await context.request.json();

    if (body is! Map || body['qr'] is! String) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'QR string is required',
        },
      );
    }

    final qr = (body['qr'] as String).trim();

    if (qr.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'success': false,
          'message': 'QR string cannot be empty',
        },
      );
    }

    final pngBytes = qrImageService.generatePng(
      data: qr,
      size: 300,
    );

    return Response.bytes(
      body: pngBytes,
      headers: {
        'content-type': 'image/png',
        'cache-control': 'no-store',
      },
    );
  } on FormatException catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': e.message,
      },
    );
  } on ArgumentError catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': e.message.toString(),
      },
    );
  } catch (e) {
    print('QR Image Error: $e');

    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'Failed to generate QR image',
      },
    );
  }
}
