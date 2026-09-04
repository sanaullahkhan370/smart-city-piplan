import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/storage_service.dart';
import '../../data/services/ambulance_service.dart';
import '../../data/services/booking_service.dart';
import 'ambulance_model.dart';

class AmbulanceController extends GetxController {
  final AmbulanceService ambulanceService =
  Get.find<AmbulanceService>();

  final BookingService bookingService =
  Get.find<BookingService>();

  final StorageService storageService =
  Get.find<StorageService>();

  final RxList<AmbulanceModel> ambulances =
      <AmbulanceModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAmbulances();
  }

  // =====================================
  // LOAD AMBULANCES
  // =====================================

  Future<void> loadAmbulances() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<AmbulanceModel> result =
      await ambulanceService.getAmbulances();

      ambulances.assignAll(result);
    } catch (error) {
      errorMessage.value = error
          .toString()
          .replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================
  // CALL DRIVER
  // =====================================

  Future<void> callDriver(String phone) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Error',
        'Phone application open نہیں ہوسکی',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =====================================
  // OPEN WHATSAPP
  // =====================================

  Future<void> openWhatsApp(
      String phone,
      ) async {
    String number = phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (number.startsWith('0')) {
      number = '92${number.substring(1)}';
    }

    const String message =
        'Assalam-o-Alaikum, mujhe ambulance '
        'service chahiye.';

    final Uri uri = Uri.parse(
      'https://wa.me/$number'
          '?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        'Error',
        'WhatsApp open نہیں ہوسکا',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =====================================
  // OPEN AMBULANCE LOCATION
  // =====================================

  Future<void> openLocation(
      double latitude,
      double longitude,
      ) async {
    if (latitude == 0 || longitude == 0) {
      Get.snackbar(
        'Location',
        'Ambulance location موجود نہیں',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/'
          '?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      Get.snackbar(
        'Error',
        'Google Maps open نہیں ہوسکا',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =====================================
  // ONE-TAP BOOKING WITH LIVE LOCATION
  // =====================================

  Future<void> bookAmbulance(
      String ambulanceId,
      ) async {
    try {
      // Login کے وقت محفوظ User حاصل کریں
      final String? savedUser =
      storageService.readUser();

      if (savedUser == null ||
          savedUser.isEmpty) {
        throw Exception(
          'Booking کے لیے دوبارہ login کریں',
        );
      }

      final Map<String, dynamic> userData =
      jsonDecode(savedUser)
      as Map<String, dynamic>;

      final String patientName =
          userData['name']
              ?.toString()
              .trim() ??
              '';

      final String phone =
          userData['phone']
              ?.toString()
              .trim() ??
              '';

      if (patientName.isEmpty) {
        throw Exception(
          'User profile میں نام موجود نہیں',
        );
      }

      if (phone.isEmpty) {
        throw Exception(
          'User profile میں phone number موجود نہیں۔ '
              'Logout کرکے دوبارہ login کریں',
        );
      }

      // پہلے location permission check کریں
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (
      permission ==
          LocationPermission.denied
      ) {
        permission =
        await Geolocator.requestPermission();
      }

      if (
      permission ==
          LocationPermission.denied
      ) {
        throw Exception(
          'Booking کے لیے Location permission ضروری ہے',
        );
      }

      if (
      permission ==
          LocationPermission.deniedForever
      ) {
        throw Exception(
          'Location permission permanently بند ہے۔ '
              'Browser یا device settings سے اجازت دیں',
        );
      }

      // Loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // User کی موجودہ live location حاصل کریں
      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Admin اس link سے pickup location کھول سکے گا
      final String liveLocation =
          'https://www.google.com/maps/search/'
          '?api=1&query='
          '${position.latitude},'
          '${position.longitude}';

      // Backend booking API call
      await bookingService.createBooking(
        ambulanceId: ambulanceId,
        patientName: patientName,
        phone: phone,
        pickupAddress: liveLocation,
        notes:
        'Booking request sent with live location',
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Request Sent',
        'آپ کی live location کے ساتھ booking '
            'request Admin کو بھیج دی گئی ہے',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      await loadAmbulances();
    } catch (error) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Booking Error',
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // =====================================
  // RATE AMBULANCE
  // =====================================

  Future<void> rateAmbulance(
      String ambulanceId,
      ) async {
    int selectedRating = 0;

    final int? rating =
    await Get.dialog<int>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Rate Ambulance Service',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اپنا تجربہ بتانے کے لیے '
                      'rating منتخب کریں',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children:
                  List.generate(5, (index) {
                    final int starNumber =
                        index + 1;

                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating =
                              starNumber;
                        });
                      },
                      icon: Icon(
                        starNumber <=
                            selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 35,
                      ),
                    );
                  }),
                ),

                if (selectedRating > 0)
                  Text(
                    '$selectedRating out of 5',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed:
                selectedRating == 0
                    ? null
                    : () {
                  Get.back(
                    result:
                    selectedRating,
                  );
                },
                child:
                const Text('Submit Rating'),
              ),
            ],
          );
        },
      ),
    );

    if (rating == null) return;

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await ambulanceService.rateAmbulance(
        ambulanceId: ambulanceId,
        rating: rating,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      await loadAmbulances();

      Get.snackbar(
        'Thank You',
        'آپ کی $rating star rating محفوظ ہوگئی ہے',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Rating Error',
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}