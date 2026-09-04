import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../modules/ambulance/ambulance_model.dart';

class AmbulanceService {
  static const String baseUrl =
      'http://localhost:5000/api';

  Future<List<AmbulanceModel>> getAmbulances() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ambulances'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData =
      jsonDecode(response.body);

      final List<dynamic> jsonList =
          decodedData['data'] ?? [];

      return jsonList
          .map(
            (json) => AmbulanceModel.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      'Ambulance data load نہیں ہوا: ${response.statusCode}',
    );
  }
  Future<void> rateAmbulance({
    required String ambulanceId,
    required int rating,
  }) async {
    final Uri url = Uri.parse(
      'http://localhost:5000/api/ambulances/'
          '$ambulanceId/rate',
    );

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
      }),
    );

    final Map<String, dynamic> responseData =
    jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        responseData['message'] ??
            'Rating submit نہیں ہوسکی',
      );
    }
  }
}