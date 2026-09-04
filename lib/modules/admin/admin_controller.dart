import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import '../../data/services/ambulance_location_service.dart';

class AdminController extends GetxController {
  final StorageService storage =
  Get.find<StorageService>();

  final AmbulanceLocationService
  locationService =
  Get.find<AmbulanceLocationService>();

  final RxBool isSharingLocation = false.obs;
  final RxString locationError = ''.obs;

  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;

  final GetConnect api = GetConnect();

  static const String baseUrl =
      'http://localhost:5000';

  final RxString adminName = 'Admin'.obs;
  final RxString adminEmail = ''.obs;

  final Rxn<Map<String, dynamic>> myAmbulance =
  Rxn<Map<String, dynamic>>();

  final RxList<Map<String, dynamic>>
  pendingBookings =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isBookingsLoading = false.obs;

  final RxString processingBookingId = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString bookingErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadAdminInformation();
    refreshDashboard();
  }

  // ==========================
  // REFRESH DASHBOARD
  // ==========================

  Future<void> refreshDashboard() async {
    await Future.wait([
      loadMyAmbulance(),
      loadPendingBookings(),
    ]);
  }

  // ==========================
  // ADMIN INFORMATION
  // ==========================

  void loadAdminInformation() {
    try {
      final String? userData =
      storage.readUser();

      if (userData == null ||
          userData.isEmpty) {
        return;
      }

      final Map<String, dynamic> user =
      jsonDecode(userData)
      as Map<String, dynamic>;

      adminName.value =
          user['name']?.toString() ?? 'Admin';

      adminEmail.value =
          user['email']?.toString() ?? '';
    } catch (_) {
      adminName.value = 'Admin';
      adminEmail.value = '';
    }
  }

  // ==========================
  // GET MY AMBULANCE
  // ==========================

  Future<void> loadMyAmbulance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String token = _requireToken();

      final Response<dynamic> response =
      await api.get(
        '$baseUrl/api/ambulances/my',
        headers: _authorizedHeaders(token),
      );

      final dynamic body =
      _getResponseBody(response);

      if (response.statusCode == 200 &&
          body is Map &&
          body['success'] == true) {
        final List<dynamic> data =
            body['data'] ?? [];

        if (data.isNotEmpty) {
          myAmbulance.value =
          Map<String, dynamic>.from(
            data.first as Map,
          );

          // MongoDB میں موجود آخری location
          // controller میں بھی محفوظ کریں
          currentLatitude.value =
              double.tryParse(
                myAmbulance
                    .value?['latitude']
                    ?.toString() ??
                    '',
              ) ??
                  0;

          currentLongitude.value =
              double.tryParse(
                myAmbulance
                    .value?['longitude']
                    ?.toString() ??
                    '',
              ) ??
                  0;

          // Ambulance Online ہو تو GPS tracking
          // خود شروع ہوگی، Offline ہو تو بند ہوگی
          await _syncLocationTracking(
            showError: false,
          );
        } else {
          myAmbulance.value = null;

          currentLatitude.value = 0;
          currentLongitude.value = 0;

          await stopLocationTracking();
        }
      } else {
        errorMessage.value =
            _responseMessage(
              body,
              'Unable to load ambulance',
            );
      }
    } catch (error) {
      errorMessage.value =
          _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> retryLocationTracking() async {
    await stopLocationTracking();

    await _syncLocationTracking(
      showError: true,
    );
  }

  // ==========================
  // GET PENDING BOOKINGS
  // ==========================

  Future<void> loadPendingBookings() async {
    try {
      isBookingsLoading.value = true;
      bookingErrorMessage.value = '';

      final String token = _requireToken();

      final Response<dynamic> response =
      await api.get(
        '$baseUrl/api/bookings/admin/active',
        headers: _authorizedHeaders(token),
      );

      final dynamic body =
      _getResponseBody(response);

      if (response.statusCode == 200 &&
          body is Map &&
          body['success'] == true) {
        final List<dynamic> data =
            body['data'] ?? [];

        pendingBookings.assignAll(
          data.map(
                (item) =>
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        );
      } else {
        bookingErrorMessage.value =
            _responseMessage(
              body,
              'Unable to load booking requests',
            );
      }
    } catch (error) {
      bookingErrorMessage.value =
          _cleanError(error);
    } finally {
      isBookingsLoading.value = false;
    }
  }

  // ==========================
  // ACCEPT BOOKING
  // ==========================

  Future<void> acceptBooking(
      String bookingId,
      ) async {
    await _updateBookingStatus(
      bookingId: bookingId,
      action: 'accept',
      successMessage:
      'Booking accepted successfully',
    );
  }

  // ==========================
// COMPLETE TRIP
// ==========================

  Future<void> completeBooking(
      String bookingId,
      ) async {
    final bool confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text(
              'Complete Trip',
            ),
            content: const Text(
              'کیا مریض کی trip مکمل ہوگئی ہے؟\n\n'
                  'Complete کرنے کے بعد Ambulance '
                  'دوبارہ Available ہوجائے گی اور '
                  'User کو Rating کا option ملے گا۔',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back(result: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.green,
                  foregroundColor:
                  Colors.white,
                ),
                icon: const Icon(
                  Icons.check_circle,
                ),
                label: const Text(
                  'Complete Trip',
                ),
              ),
            ],
          ),
        ) ??
            false;

    if (!confirmed) return;

    await _updateBookingStatus(
      bookingId: bookingId,
      action: 'complete',
      successMessage:
      'Trip completed successfully',
    );
  }

  // ==========================
  // REJECT BOOKING
  // ==========================

  Future<void> rejectBooking(
      String bookingId,
      ) async {
    final bool confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text(
              'Reject Booking',
            ),
            content: const Text(
              'کیا آپ اس booking request کو '
                  'reject کرنا چاہتے ہیں؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(result: false);
                },
                child:
                const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: true);
                },
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.red,
                  foregroundColor:
                  Colors.white,
                ),
                child:
                const Text('Reject'),
              ),
            ],
          ),
        ) ??
            false;

    if (!confirmed) return;

    await _updateBookingStatus(
      bookingId: bookingId,
      action: 'reject',
      successMessage: 'Booking rejected',
    );
  }

  // ==========================
  // ACCEPT / REJECT API
  // ==========================

  Future<void> _updateBookingStatus({
    required String bookingId,
    required String action,
    required String successMessage,
  }) async {
    if (bookingId.isEmpty ||
        processingBookingId.value.isNotEmpty) {
      return;
    }

    try {
      processingBookingId.value = bookingId;

      final String token = _requireToken();

      final Uri url = Uri.parse(
        '$baseUrl/api/bookings/'
            '$bookingId/$action',
      );

      debugPrint(
        'Booking action URL: $url',
      );

      final http.Response response =
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      debugPrint(
        'Booking status: ${response.statusCode}',
      );

      debugPrint(
        'Booking response: ${response.body}',
      );

      Map<String, dynamic> body = {};

      try {
        body = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Server returned an invalid response: '
              '${response.body}',
        );
      }

      if (response.statusCode == 200 &&
          body['success'] == true) {
        Get.snackbar(
          'Success',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await refreshDashboard();
      } else {
        Get.snackbar(
          'Booking Failed',
          body['message']?.toString() ??
              'Status ${response.statusCode}: '
                  'Unable to update booking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (error) {
      debugPrint(
        'Booking action error: $error',
      );

      Get.snackbar(
        'Booking Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      processingBookingId.value = '';
    }
  }

  // ==========================
  // OPEN PICKUP LOCATION
  // ==========================

  Future<void> openPickupLocation(
      String pickupAddress,
      ) async {
    if (pickupAddress.trim().isEmpty) {
      Get.snackbar(
        'Location',
        'Pickup location موجود نہیں',
      );

      return;
    }

    final String value =
    pickupAddress.trim();

    final Uri uri =
    value.startsWith('http')
        ? Uri.parse(value)
        : Uri.parse(
      'https://www.google.com/maps/'
          'search/?api=1&query='
          '${Uri.encodeComponent(value)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        'Location Error',
        'Google Maps open نہیں ہوسکا',
      );
    }
  }

  // ==========================
// ONLINE / OFFLINE
// ==========================

  Future<void> changeOnlineStatus(
      bool newValue,
      ) async {
    final Map<String, dynamic>? ambulance =
        myAmbulance.value;

    if (ambulance == null) return;

    final String ambulanceId =
        ambulance['_id']?.toString() ?? '';

    if (ambulanceId.isEmpty) return;

    await updateAvailability(
      ambulanceId: ambulanceId,
      isOnline: newValue,
    );

    await _syncLocationTracking(
      showError: true,
    );
  }

// ==========================
// SYNC LOCATION TRACKING
// ==========================

  Future<void> _syncLocationTracking({
    required bool showError,
  }) async {
    final Map<String, dynamic>? ambulance =
        myAmbulance.value;

    if (ambulance == null) {
      await stopLocationTracking();
      return;
    }

    final bool isOnline =
        ambulance['isOnline'] == true;

    if (!isOnline) {
      await stopLocationTracking();
      return;
    }

    if (locationService.isTracking) {
      isSharingLocation.value = true;
      return;
    }

    final String ambulanceId =
        ambulance['_id']?.toString() ?? '';

    if (ambulanceId.isEmpty) return;

    locationError.value = '';

    await locationService.startTracking(
      ambulanceId: ambulanceId,
      onLocationUpdated: (
          Position position,
          ) {
        isSharingLocation.value = true;
        locationError.value = '';

        currentLatitude.value =
            position.latitude;

        currentLongitude.value =
            position.longitude;

        final Map<String, dynamic>
        updatedAmbulance =
        Map<String, dynamic>.from(
          myAmbulance.value ?? {},
        );

        updatedAmbulance['latitude'] =
            position.latitude;

        updatedAmbulance['longitude'] =
            position.longitude;

        updatedAmbulance[
        'locationUpdatedAt'
        ] = DateTime.now()
            .toUtc()
            .toIso8601String();

        myAmbulance.value =
            updatedAmbulance;
      },
      onError: (String message) {
        locationError.value = message;

        isSharingLocation.value =
            locationService.isTracking;

        if (showError) {
          Get.snackbar(
            'Location Error',
            message,
            snackPosition:
            SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration:
            const Duration(seconds: 5),
          );
        }
      },
    );

    isSharingLocation.value =
        locationService.isTracking;
  }

// ==========================
// STOP LOCATION TRACKING
// ==========================

  Future<void> stopLocationTracking() async {
    await locationService.stopTracking();

    isSharingLocation.value = false;
    locationError.value = '';
  }

  // ==========================
  // AVAILABLE / BUSY
  // ==========================

  Future<void> changeAmbulanceStatus(
      String? newStatus,
      ) async {
    if (newStatus == null) return;

    final Map<String, dynamic>? ambulance =
        myAmbulance.value;

    if (ambulance == null) return;

    final bool isOnline =
        ambulance['isOnline'] == true;

    if (!isOnline) {
      Get.snackbar(
        'Ambulance Offline',
        'پہلے Ambulance کو Online کریں',
      );

      return;
    }

    final String ambulanceId =
        ambulance['_id']?.toString() ?? '';

    if (ambulanceId.isEmpty) return;

    await updateAvailability(
      ambulanceId: ambulanceId,
      status: newStatus,
    );
  }

  // ==========================
  // UPDATE AVAILABILITY
  // ==========================

  Future<void> updateAvailability({
    required String ambulanceId,
    bool? isOnline,
    String? status,
  }) async {
    try {
      isUpdating.value = true;

      final String token = _requireToken();

      final Map<String, dynamic> requestBody = {};

      if (isOnline != null) {
        requestBody['isOnline'] = isOnline;
      }

      if (status != null) {
        requestBody['status'] = status;
      }

      final Uri url = Uri.parse(
        '$baseUrl/api/ambulances/'
            '$ambulanceId/availability',
      );

      debugPrint(
        'Availability URL: $url',
      );

      debugPrint(
        'Availability request: $requestBody',
      );

      final http.Response response =
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint(
        'Availability status: '
            '${response.statusCode}',
      );

      debugPrint(
        'Availability response: '
            '${response.body}',
      );

      Map<String, dynamic> body = {};

      try {
        body = jsonDecode(response.body)
        as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Server returned an invalid response: '
              '${response.body}',
        );
      }

      if (response.statusCode == 200 &&
          body['success'] == true) {
        final Map<String, dynamic> updatedData =
        Map<String, dynamic>.from(
          body['data'] ?? {},
        );

        final Map<String, dynamic>
        currentAmbulance =
        Map<String, dynamic>.from(
          myAmbulance.value ?? {},
        );

        currentAmbulance['isOnline'] =
        updatedData['isOnline'];

        currentAmbulance['status'] =
        updatedData['status'];

        myAmbulance.value = currentAmbulance;

        Get.snackbar(
          'Success',
          updatedData['isOnline'] == true
              ? 'Ambulance is now Online'
              : 'Ambulance is now Offline',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Update Failed',
          body['message']?.toString() ??
              'Status ${response.statusCode}: '
                  'Unable to update ambulance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (error) {
      debugPrint(
        'Availability error: $error',
      );

      Get.snackbar(
        'Update Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  // ==========================
  // HELPERS
  // ==========================

  String _requireToken() {
    final String? token =
    storage.readToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token is missing',
      );
    }

    return token;
  }

  Map<String, String> _authorizedHeaders(
      String token,
      ) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  dynamic _getResponseBody(
      Response<dynamic> response,
      ) {
    if (response.body is Map) {
      return response.body;
    }

    final String? bodyString =
        response.bodyString;

    if (bodyString == null ||
        bodyString.isEmpty) {
      return response.body;
    }

    try {
      return jsonDecode(bodyString);
    } catch (_) {
      return bodyString;
    }
  }

  String _responseMessage(
      dynamic body,
      String fallback,
      ) {
    if (body is Map) {
      return body['message']
          ?.toString() ??
          fallback;
    }

    if (body is String &&
        body.trim().isNotEmpty) {
      return body;
    }

    return fallback;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ==========================
  // NAVIGATION
  // ==========================

  void openAmbulances() {
    Get.toNamed(AppRoutes.ambulance);
  }

  void openHospitals() {
    Get.snackbar(
      'Hospitals',
      'Hospital management screen '
          'اگلے مرحلے میں بنائیں گے',
    );
  }

  void openDoctors() {
    Get.snackbar(
      'Doctors',
      'Doctor management screen '
          'اگلے مرحلے میں بنائیں گے',
    );
  }

  void openPharmacies() {
    Get.snackbar(
      'Pharmacies',
      'Pharmacy management screen '
          'اگلے مرحلے میں بنائیں گے',
    );
  }

  // ==========================
  // LOGOUT
  // ==========================

  Future<void> logout() async {
    await storage.clearAll();

    Get.offAllNamed(AppRoutes.login);
  }
}
