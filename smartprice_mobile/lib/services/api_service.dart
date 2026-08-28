import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_comparison.dart';

class ApiService {
  // Returns appropriate localhost address depending on platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://127.0.0.1:8000'; // Works with adb reverse & direct emulator loopback
    } else {
      return 'http://localhost:8000'; // iOS Simulator & Desktop
    }
  }

  final String baseUrl;

  ApiService({String? customBaseUrl})
      : baseUrl = customBaseUrl ?? defaultBaseUrl;

  Future<List<ProductComparison>> compareProducts({
    required String query,
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/compare').replace(
      queryParameters: {
        'query': query,
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsRaw = data['products'] ?? [];
        return productsRaw
            .map((item) => ProductComparison.fromJson(item))
            .toList();
      } else {
        throw Exception('Server returned error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to comparison server: $e');
    }
  }
}
