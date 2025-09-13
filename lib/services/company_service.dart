import 'dart:convert';
import 'api_service.dart';

class CompanyService {
  static Future<Map<String, dynamic>> fetchCompanyProfile(
    String companyId,
  ) async {
    final response = await ApiService.getRequest('company/$companyId');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateCompanyInfo({
    required String companyId,
    required String name,
    required String email,
    required String password,
    required String type,
    required String about,
    required String latitude,
    required String longitude,
  }) async {
    final response = await ApiService.putRequest('company/$companyId', {
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
}
