import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BakongService {
  final String token;
  final String baseUrl;
  final http.Client client;

  BakongService({
    required this.token,
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> checkTransactionByMd5(
    String md5,
  ) async {
    if (token.trim().isEmpty) {
      throw StateError('Bakong token is missing');
    }

    if (md5.trim().isEmpty) {
      throw ArgumentError('MD5 must not be empty');
    }

    final uri = Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}'
      '/v1/check_transaction_by_md5',
    );

    if (uri.scheme != 'https') {
      throw StateError('Bakong API must use HTTPS');
    }

    final response = await client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'md5': md5.trim().toLowerCase(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Bakong API returned HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid Bakong API response',
      );
    }

    return decoded;
  }

  void close() {
    client.close();
  }
}
