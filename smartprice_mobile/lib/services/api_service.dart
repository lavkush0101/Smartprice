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
    String category = 'all',
    required double lat,
    required double lng,
  }) async {
    final effectiveQuery = query.trim().isEmpty ? 'all' : query.trim();
    final uri = Uri.parse('$baseUrl/api/v1/compare').replace(
      queryParameters: {
        'query': effectiveQuery,
        'category': category,
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

  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/categories');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['categories'] ?? [];
        return list.map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
          'icon': item['icon'].toString(),
        }).toList();
      }
    } catch (_) {}

    // Fallback default categories
    return [
      {"id": "all", "name": "All Products", "icon": "🔥"},
      {"id": "dairy", "name": "Dairy & Breakfast", "icon": "🥛"},
      {"id": "fruits_veg", "name": "Fruits & Veg", "icon": "🍎"},
      {"id": "bakery", "name": "Bakery & Eggs", "icon": "🍞"},
      {"id": "snacks", "name": "Snacks", "icon": "🍿"},
      {"id": "drinks", "name": "Cold Drinks", "icon": "🥤"},
      {"id": "staples", "name": "Atta & Staples", "icon": "🍚"},
      {"id": "sweets", "name": "Chocolates", "icon": "🍫"},
      {"id": "tea_coffee", "name": "Tea & Coffee", "icon": "☕"},
      {"id": "cleaning", "name": "Cleaning", "icon": "🧹"},
      {"id": "personal_care", "name": "Personal Care", "icon": "✨"},
    ];
  }

  Future<Map<String, dynamic>?> detectLiveLocation() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/location/detect');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/location/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
