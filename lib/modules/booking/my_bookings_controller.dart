import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes/app_routes.dart';

import '../../data/services/booking_service.dart';

class MyBookingsController
    extends GetxController {
  final BookingService bookingService =
  Get.find<BookingService>();

  final RxList<Map<String, dynamic>>
  bookings =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString ratingBookingId = ''.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();

    loadBookings();

    // Accepted trip کے دوران Ambulance کی
    // نئی location ہر 10 سیکنڈ بعد حاصل ہوگی
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        loadBookings(showLoading: false);
      },
    );
  }

  // =========================
  // LOAD MY BOOKINGS
  // =========================

  Future<void> loadBookings({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      errorMessage.value = '';

      final List<Map<String, dynamic>>
      result =
      await bookingService.getMyBookings();

      bookings.assignAll(result);

      // Completed اور unrated trip تلاش کریں
      final bool ratingRequired =
      result.any((booking) {
        final String status =
            booking['status']
                ?.toString() ??
                '';

        final bool isRated =
            booking['isRated'] == true;

        return status == 'completed' &&
            !isRated;
      });

      if (ratingRequired &&
          Get.currentRoute !=
              AppRoutes.requiredRating) {
        Get.offAllNamed(
          AppRoutes.requiredRating,
        );
      }
    } catch (error) {
      errorMessage.value =
          _cleanError(error);
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
  // =========================
  // RATE COMPLETED TRIP
  // =========================

  Future<void> rateBooking(
      String bookingId,
      ) async {
    int selectedRating = 0;

    final int? rating =
    await Get.dialog<int>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Rate Your Trip',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ambulance service کا '
                      'اپنا تجربہ بتائیں',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children:
                  List.generate(5, (index) {
                    final int star =
                        index + 1;

                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating = star;
                        });
                      },
                      icon: Icon(
                        star <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
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
      ratingBookingId.value = bookingId;

      await bookingService
          .rateCompletedBooking(
        bookingId: bookingId,
        rating: rating,
      );

      Get.snackbar(
        'Thank You',
        'آپ کی $rating star rating '
            'محفوظ ہوگئی ہے',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadBookings(
        showLoading: false,
      );
    } catch (error) {
      Get.snackbar(
        'Rating Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      ratingBookingId.value = '';
    }
  }

  // =========================
  // OPEN AMBULANCE LOCATION
  // =========================

  Future<void> openAmbulanceLocation(
      Map<String, dynamic> ambulance,
      ) async {
    final double latitude =
        double.tryParse(
          ambulance['latitude']
              ?.toString() ??
              '',
        ) ??
            0;

    final double longitude =
        double.tryParse(
          ambulance['longitude']
              ?.toString() ??
              '',
        ) ??
            0;

    if (latitude == 0 || longitude == 0) {
      Get.snackbar(
        'Location',
        'Ambulance کی live location '
            'ابھی موجود نہیں',
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

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}