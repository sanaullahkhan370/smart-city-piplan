import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../modules/vehicle/vehicle_model.dart';

class VehicleService {
  static const String baseUrl =
      'http://localhost:5000/api';

  // ==================================
  // GET PUBLIC VEHICLES
  // ==================================

  Future<List<VehicleModel>> getVehicles({
    required String serviceType,
  }) async {
    final String normalizedType =
    serviceType.trim().toLowerCase();

    if (normalizedType.isEmpty) {
      throw Exception(
        'Vehicle service type is required',
      );
    }

    final Uri url = Uri.parse(
      '$baseUrl/vehicles',
    ).replace(
      queryParameters: {
        'serviceType': normalizedType,
      },
    );

    try {
      final http.Response response =
      await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> body =
      _decodeResponse(response);

      if (response.statusCode == 200 &&
          body['success'] == true) {
        final dynamic responseData =
        body['data'];

        if (responseData is! List) {
          return [];
        }

        return responseData
            .whereType<Map>()
            .map(
              (item) => VehicleModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
            .toList();
      }

      throw Exception(
        body['message']?.toString() ??
            'Vehicles load نہیں ہوسکیں',
      );
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Server سے رابطہ نہیں ہوسکا: $error',
      );
    }
  }

  // ==================================
  // RESPONSE DECODER
  // ==================================

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    if (response.body.trim().isEmpty) {
      throw Exception(
        'Server سے خالی response ملا',
      );
    }

    try {
      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }

      throw Exception(
        'Server response درست format میں نہیں',
      );
    } catch (error) {
      throw Exception(
        'Server سے درست response نہیں ملا: '
            '${response.body}',
      );
    }
  }
}