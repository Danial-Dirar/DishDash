import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class MenuService {
  static Future<Map<String, dynamic>> uploadMenuImage(
    String companyId,
    File imageFile,
  ) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/company/$companyId/menu');

      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'menu_image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (responseData.statusCode >= 200 && responseData.statusCode < 300) {
        return json.decode(responseData.body);
      } else {
        throw Exception('Failed to upload menu image: ${responseData.body}');
      }
    } catch (e) {
      throw Exception('Error uploading menu image: $e');
    }
  }

  static Future<Map<String, dynamic>> getMenuImage(String companyId) async {
    try {
      final response = await ApiService.getRequest('company/$companyId/menu');
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error fetching menu image: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteMenuImage(String companyId) async {
    try {
      final response = await ApiService.deleteRequest(
        'company/$companyId/menu',
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error deleting menu image: $e');
    }
  }

  // Additional utility methods
  static Future<bool> hasMenuImage(String companyId) async {
    try {
      final result = await getMenuImage(companyId);
      return result['menu_image_url'] != null &&
          result['menu_image_url'].isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static String? getMenuImageUrl(Map<String, dynamic> menuData) {
    return menuData['menu_image_url'];
  }
}
