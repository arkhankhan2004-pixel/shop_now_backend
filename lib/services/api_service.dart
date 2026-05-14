import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import '../models/order_model.dart';

class ApiService {
  // Use localhost for web, and current IP for mobile
  static const String ngrokUrl = 'https://paola-unsmothering-crunchily.ngrok-free.dev';
  
  static String get baseUrl => kIsWeb ? 'http://localhost:5001/api' : '$ngrokUrl/api';
  static String get serverUrl => kIsWeb ? 'http://localhost:5001' : ngrokUrl;

  // ==================== PRODUCTS ====================

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((j) => Product.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addProduct({
    required String name,
    required String description,
    required String price,
    required String category,
    int discountPercent = 0,
    String? imagePath,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
      request.fields['discount_percent'] = discountPercent.toString();
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price;
      request.fields['category'] = category;
      request.headers['ngrok-skip-browser-warning'] = '69420';

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
      } else if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var streamedResponse = await request.send();
      return streamedResponse.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> editProduct({
    required int id,
    required String name,
    required String description,
    required String price,
    required String category,
    int discountPercent = 0,
    String? imagePath,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/products/$id'));
      request.fields['discount_percent'] = discountPercent.toString();
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price;
      request.fields['category'] = category;
      request.headers['ngrok-skip-browser-warning'] = '69420';

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
      } else if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> bulkDeleteProducts(List<int> ids) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/bulk-delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== ORDERS ====================

  static Future<bool> placeOrder({
    required String firebaseUid,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String paymentMethod,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
        },
        body: json.encode({
          'firebase_uid': firebaseUid,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'payment_method': paymentMethod,
          'total_amount': totalAmount,
          'items': items,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('❌ ORDER API ERROR: $e');
      return false;
    }
  }

  static Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((j) => OrderModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<OrderModel>> getUserOrders(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$uid'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((j) => OrderModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
