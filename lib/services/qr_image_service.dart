import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

class QrImageService {
  Uint8List generatePng({
    required String data,
    int size = 300,
  }) {
    if (data.trim().isEmpty) {
      throw ArgumentError('QR data must not be empty');
    }

    if (size < 128 || size > 2000) {
      throw ArgumentError(
        'Image size must be between 128 and 2000',
      );
    }

    // Create QR Payload from KHQR String
    final payload = QrPayload.fromString(data.trim());

    // Generate QR Code
    final qrCode = QrCode(
      payload: payload,
      errorCorrectLevel: QrErrorCorrectLevel.medium,
    );

    final qrImage = QrImage(qrCode);

    // QR Quiet Zone
    const quietZone = 4;

    final moduleCount = qrImage.moduleCount;
    final totalModules = moduleCount + (quietZone * 2);

    final scale = size ~/ totalModules;

    if (scale < 1) {
      throw ArgumentError('Image size is too small');
    }

    final actualSize = totalModules * scale;

    // Create white background
    final image = img.Image(
      width: actualSize,
      height: actualSize,
    );

    img.fill(
      image,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Draw QR Modules
    for (var y = 0; y < moduleCount; y++) {
      for (var x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          for (var dy = 0; dy < scale; dy++) {
            for (var dx = 0; dx < scale; dx++) {
              image.setPixel(
                (x + quietZone) * scale + dx,
                (y + quietZone) * scale + dy,
                img.ColorRgb8(0, 0, 0),
              );
            }
          }
        }
      }
    }

    // Convert Image to PNG Bytes
    return Uint8List.fromList(
      img.encodePng(image),
    );
  }
}
