import 'dart:convert';
import 'api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.postRequest('user/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return json.decode(response.body);
  }

  static Future<List<dynamic>> fetchSavedOffers(String userId) async {
    final response = await ApiService.getRequest('user/$userId/saved_offers');
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> saveOffer(
    String userId,
    String offerId,
  ) async {
    final response = await ApiService.postRequest('user/$userId/save_offer', {
      'offer_id': offerId,
    });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> removeSavedOffer(
    String userId,
    String offerId,
  ) async {
    final response = await ApiService.postRequest(
      'user/$userId/remove_saved_offer',
      {'offer_id': offerId},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    final response = await ApiService.postRequest('auth/reset_password', {
      'email': email,
    });
    return json.decode(response.body);
  }
}
