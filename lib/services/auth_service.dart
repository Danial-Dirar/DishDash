import 'dart:convert';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.postRequest('login', {
      'email': email,
      'password': password,
    });

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final response = await ApiService.postRequest('register_user', {
      'name': name,
      'email': email,
      'password': password,
    });

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> registerCompany({
    required String name,
    required String email,
    required String password,
    required String type,
    required String about,
    required String latitude,
    required String longitude,
  }) async {
    final response = await ApiService.postRequest('register_company', {
      'name': name,
      'email': email,
      'password': password,
      'type': type,
      'about': about,
      'latitude': latitude,
      'longitude': longitude,
    });

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    final response = await ApiService.postRequest('reset_password', {
      'email': email,
    });

    return json.decode(response.body);
  }
}
