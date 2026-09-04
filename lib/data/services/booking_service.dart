import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../core/storage/storage_service.dart';

class BookingService {
  static const String baseUrl =
      'http://localhost:5000/api';

  final StorageService storageService =
  Get.find<StorageService>();

  // ==================================
  // CREATE BOOKING
  // ==================================
  //
  // نئی Generic booking:
  // vehicleId + customerName
  //
  // پرانی Ambulance booking:
  // ambulanceId + patientName
  //

  Future<Map<String, dynamic>> createBooking({
    String? vehicleId,
    String? ambulanceId,
    String? customerName,
    String? patientName,
    required String phone,
    required String pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String notes = '',
  }) async {
    final String token = _requireToken();

    final String selectedVehicleId =
        vehicleId?.trim() ?? '';

    final String selectedAmbulanceId =
        ambulanceId?.trim() ?? '';

    final String bookingName =
    customerName?.trim().isNotEmpty == true
        ? customerName!.trim()
        : patientName?.trim() ?? '';

    if (selectedVehicleId.isEmpty &&
        selectedAmbulanceId.isEmpty) {
      throw Exception(
        'Vehicle ID is required',
      );
    }

    if (bookingName.isEmpty) {
      throw Exception(
        'Customer name is required',
      );
    }

    if (phone.trim().isEmpty) {
      throw Exception(
        'Phone number is required',
      );
    }

    if (pickupAddress.trim().isEmpty) {
      throw Exception(
        'Pickup address is required',
      );
    }

    final Map<String, dynamic> requestBody = {
      'customerName': bookingName,
      'patientName': bookingName,
      'phone': phone.trim(),
      'pickupAddress':
      pickupAddress.trim(),
      'notes': notes.trim(),
    };

    // نئی Generic Vehicle booking
    if (selectedVehicleId.isNotEmpty) {
      requestBody['vehicleId'] =
          selectedVehicleId;
    }

    // پرانی Ambulance booking compatibility
    if (selectedVehicleId.isEmpty &&
        selectedAmbulanceId.isNotEmpty) {
      requestBody['ambulanceId'] =
          selectedAmbulanceId;
    }

    if (pickupLatitude != null) {
      requestBody['pickupLatitude'] =
          pickupLatitude;
    }

    if (pickupLongitude != null) {
      requestBody['pickupLongitude'] =
          pickupLongitude;
    }

    final http.Response response =
    await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _authorizedHeaders(token),
      body: jsonEncode(requestBody),
    );

    final Map<String, dynamic> data =
    _decodeResponse(response);

    if (response.statusCode != 201 ||
        data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Booking request نہیں بھیجی جاسکی',
      );
    }

    return data;
  }

  // ==================================
  // USER: MY BOOKINGS
  // ==================================

  Future<List<Map<String, dynamic>>>
  getMyBookings() async {
    final String token = _requireToken();

    final http.Response response =
    await http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: _authorizedHeaders(token),
    );

    final Map<String, dynamic> data =
    _decodeResponse(response);

    if (response.statusCode != 200 ||
        data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Bookings load نہیں ہوسکیں',
      );
    }

    final dynamic responseData =
    data['data'];

    if (responseData is! List) {
      return [];
    }

    return responseData
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  // ==================================
  // USER: RATE COMPLETED TRIP
  // ==================================

  Future<Map<String, dynamic>>
  rateCompletedBooking({
    required String bookingId,
    required int rating,
  }) async {
    final String token = _requireToken();

    if (bookingId.trim().isEmpty) {
      throw Exception(
        'Booking ID is required',
      );
    }

    if (rating < 1 || rating > 5) {
      throw Exception(
        'Rating must be between 1 and 5',
      );
    }

    final http.Response response =
    await http.patch(
      Uri.parse(
        '$baseUrl/bookings/'
            '${bookingId.trim()}/rate',
      ),
      headers: _authorizedHeaders(token),
      body: jsonEncode({
        'rating': rating,
      }),
    );

    final Map<String, dynamic> data =
    _decodeResponse(response);

    if (response.statusCode != 200 ||
        data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Rating submit نہیں ہوسکی',
      );
    }

    return data;
  }

  // ==================================
  // COMPLETED UNRATED BOOKING
  // ==================================

  Future<Map<String, dynamic>?>
  getCompletedUnratedBooking() async {
    final List<Map<String, dynamic>>
    bookings = await getMyBookings();

    for (final booking in bookings) {
      final String status =
          booking['status']
              ?.toString()
              .toLowerCase() ??
              '';

      final bool isRated =
          booking['isRated'] == true;

      if (status == 'completed' &&
          !isRated) {
        return booking;
      }
    }

    return null;
  }

  // ==================================
  // ACTIVE USER BOOKING
  // ==================================

  Future<Map<String, dynamic>?>
  getActiveBooking() async {
    final List<Map<String, dynamic>>
    bookings = await getMyBookings();

    for (final booking in bookings) {
      final String status =
          booking['status']
              ?.toString()
              .toLowerCase() ??
              '';

      if (status == 'pending' ||
          status == 'accepted') {
        return booking;
      }
    }

    return null;
  }

  // ==================================
  // HELPERS
  // ==================================

  String _requireToken() {
    final String? token =
    storageService.readToken();

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'Please login again',
      );
    }

    return token.trim();
  }

  Map<String, String> _authorizedHeaders(
      String token,
      ) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    if (response.body.trim().isEmpty) {
      throw Exception(
        'Server returned an empty response',
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
        'Server response is not an object',
      );
    } catch (_) {
      throw Exception(
        'Server returned an invalid response: '
            '${response.body}',
      );
    }
  }
}