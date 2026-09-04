import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/storage_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/vehicle_service.dart';
import 'vehicle_model.dart';

class VehicleController extends GetxController {
  final VehicleService vehicleService =
  Get.find<VehicleService>();

  final BookingService bookingService =
  Get.find<BookingService>();

  final StorageService storageService =
  Get.find<StorageService>();

  final RxList<VehicleModel> vehicles =
      <VehicleModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString serviceType = ''.obs;
  final RxString pageTitle = 'Vehicles'.obs;

  // جس Vehicle کی booking چل رہی ہو
  final RxString bookingVehicleId = ''.obs;

  String userName = '';
  String userPhone = '';

  @override
  void onInit() {
    super.onInit();

    _readRouteArguments();
    _loadUserInformation();
    loadVehicles();
  }

  // ==================================
  // READ ROUTE ARGUMENTS
  // ==================================

  void _readRouteArguments() {
    final dynamic arguments = Get.arguments;

    if (arguments is Map) {
      serviceType.value =
          arguments['serviceType']
              ?.toString()
              .trim()
              .toLowerCase() ??
              '';

      pageTitle.value =
          arguments['title']
              ?.toString()
              .trim() ??
              '';
    }

    // Browser refresh/query support
    if (serviceType.value.isEmpty) {
      serviceType.value =
          Get.parameters['type']
              ?.toString()
              .trim()
              .toLowerCase() ??
              '';
    }

    if (serviceType.value.isEmpty) {
      serviceType.value = 'ambulance';
    }

    if (pageTitle.value.isEmpty) {
      pageTitle.value = _getPageTitle(
        serviceType.value,
      );
    }
  }

  String _getPageTitle(String type) {
    switch (type) {
      case 'ambulance':
        return 'Ambulances';

      case 'rickshaw':
        return 'Rickshaws';

      case 'mazda':
        return 'Mazda';

      case 'pickup':
        return 'Pickups';

      case 'truck':
        return 'Trucks';

      default:
        return 'Vehicles';
    }
  }

  // ==================================
  // LOAD LOGGED-IN USER
  // ==================================

  void _loadUserInformation() {
    final String? userJson =
    storageService.readUser();

    if (userJson == null ||
        userJson.trim().isEmpty) {
      return;
    }

    try {
      final dynamic decoded =
      jsonDecode(userJson);

      if (decoded is Map) {
        userName =
            decoded['name']
                ?.toString()
                .trim() ??
                '';

        userPhone =
            decoded['phone']
                ?.toString()
                .trim() ??
                '';
      }
    } catch (_) {
      userName = '';
      userPhone = '';
    }
  }

  // ==================================
  // LOAD VEHICLES
  // ==================================

  Future<void> loadVehicles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<VehicleModel> result =
      await vehicleService.getVehicles(
        serviceType: serviceType.value,
      );

      vehicles.assignAll(result);
    } catch (error) {
      errorMessage.value =
          _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshVehicles() async {
    await loadVehicles();
  }

  // ==================================
  // CALL DRIVER
  // ==================================

  Future<void> callDriver(
      String phone,
      ) async {
    if (phone.trim().isEmpty) {
      Get.snackbar(
        'Phone',
        'Driver کا phone number موجود نہیں',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    final Uri uri = Uri(
      scheme: 'tel',
      path: phone.trim(),
    );

    final bool opened =
    await launchUrl(uri);

    if (!opened) {
      Get.snackbar(
        'Error',
        'Phone application open نہیں ہوسکی',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================================
  // OPEN WHATSAPP
  // ==================================

  Future<void> openWhatsApp(
      String whatsappNumber,
      String phone,
      ) async {
    String number =
    whatsappNumber.trim();

    if (number.isEmpty) {
      number = phone.trim();
    }

    number = number.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (number.startsWith('0')) {
      number =
      '92${number.substring(1)}';
    }

    if (number.isEmpty) {
      Get.snackbar(
        'WhatsApp',
        'WhatsApp number موجود نہیں',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    final String message =
    serviceType.value == 'ambulance'
        ? 'Assalam-o-Alaikum, mujhe '
        'ambulance service chahiye.'
        : 'Assalam-o-Alaikum, mujhe '
        '${pageTitle.value} service '
        'chahiye.';

    final Uri uri = Uri.parse(
      'https://wa.me/$number'
          '?text=${Uri.encodeComponent(message)}',
    );

    final bool opened =
    await launchUrl(
      uri,
      mode:
      LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.snackbar(
        'Error',
        'WhatsApp open نہیں ہوسکا',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================================
  // OPEN VEHICLE LOCATION
  // ==================================

  Future<void> openLocation(
      VehicleModel vehicle,
      ) async {
    if (!vehicle.hasLocation) {
      Get.snackbar(
        'Location',
        'Vehicle location موجود نہیں',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/'
          '?api=1&query='
          '${vehicle.latitude},'
          '${vehicle.longitude}',
    );

    final bool opened =
    await launchUrl(
      uri,
      mode:
      LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.snackbar(
        'Error',
        'Google Maps open نہیں ہوسکا',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================================
  // BOOK GENERIC VEHICLE
  // ==================================

  Future<void> bookVehicle(
      VehicleModel vehicle,
      ) async {
    if (!vehicle.isAvailable) {
      Get.snackbar(
        'Unavailable',
        'یہ ${vehicle.displayServiceName} '
            'ابھی available نہیں ہے',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      return;
    }

    if (bookingVehicleId.value.isNotEmpty) {
      return;
    }

    try {
      bookingVehicleId.value =
          vehicle.id;

      // SharedPreferences سے دوبارہ
      // تازہ User data حاصل کریں
      _loadUserInformation();

      if (userName.isEmpty ||
          userPhone.isEmpty) {
        throw Exception(
          'آپ کا نام یا phone number موجود '
              'نہیں۔ براہ کرم دوبارہ login کریں',
        );
      }

      // User کی موجودہ GPS location
      final Position position =
      await _getCurrentPosition();

      await bookingService.createBooking(
        vehicleId: vehicle.id,
        customerName: userName,
        phone: userPhone,

        // Address کی جگہ فی الحال GPS label
        // Admin کو coordinates بھی ملیں گے
        pickupAddress:
        'Live GPS Location',

        pickupLatitude:
        position.latitude,

        pickupLongitude:
        position.longitude,

        notes:
        '${vehicle.displayServiceName} '
            'booking request',
      );

      Get.snackbar(
        'Booking Sent',
        '${vehicle.displayServiceName} '
            'booking request Admin کو '
            'بھیج دی گئی ہے',
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration:
        const Duration(seconds: 4),
      );

      await loadVehicles();
    } catch (error) {
      Get.snackbar(
        'Booking Error',
        _cleanError(error),
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration:
        const Duration(seconds: 6),
      );
    } finally {
      bookingVehicleId.value = '';
    }
  }

  // ==================================
  // GET USER LIVE GPS LOCATION
  // ==================================

  Future<Position>
  _getCurrentPosition() async {
    final bool serviceEnabled =
    await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location service بند ہے۔ '
            'براہ کرم GPS On کریں',
      );
    }

    LocationPermission permission =
    await Geolocator
        .checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
      await Geolocator
          .requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      throw Exception(
        'Location permission نہیں ملی',
      );
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently '
            'denied ہے۔ Browser/App settings '
            'سے permission دیں',
      );
    }

    return Geolocator
        .getCurrentPosition(
      locationSettings:
      const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // ==================================
  // BOOKING BUTTON STATE
  // ==================================

  bool isBookingVehicle(
      String vehicleId,
      ) {
    return bookingVehicleId.value ==
        vehicleId;
  }

  // ==================================
  // ERROR CLEANER
  // ==================================

  String _cleanError(dynamic error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}