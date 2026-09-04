import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'http://localhost:5000/api/auth';

  // =========================
  // REGISTER
  // =========================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final Uri url =
      Uri.parse('$baseUrl/register');

      final http.Response response =
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> data =
      jsonDecode(response.body)
      as Map<String, dynamic>;

      return data;
    } catch (error) {
      return {
        'success': false,
        'message':
        'Unable to connect to server: $error',
      };
    }
  }

  // =========================
  // LOGIN
  // =========================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Uri url =
      Uri.parse('$baseUrl/login');

      final http.Response response =
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final Map<String, dynamic> data =
      jsonDecode(response.body)
      as Map<String, dynamic>;

      return data;
    } catch (error) {
      return {
        'success': false,
        'message':
        'Unable to connect to server: $error',
      };
    }
  }
}