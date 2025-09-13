import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class OfferService {
  static Future<Map<String, dynamic>> postOffer({
    required String companyId,
    required String title,
    required String description,
    required File imageFile,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/company/$companyId/offer');

    var request = http.MultipartRequest('POST', url);
    request.fields['title'] = title;
    request.fields['description'] = description;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    return json.decode(responseData.body);
  }

  static Future<List<dynamic>> fetchCompanyOffers(String companyId) async {
    final response = await ApiService.getRequest('company/$companyId/offers');
    return json.decode(response.body);
  }

  static Future<List<dynamic>> fetchNearbyOffers({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final response = await ApiService.getRequest(
      'offers?lat=$latitude&lng=$longitude&radius=$radius',
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteOffer(String offerId) async {
    final response = await ApiService.deleteRequest('offer/$offerId');
    return json.decode(response.body);
  }
}
