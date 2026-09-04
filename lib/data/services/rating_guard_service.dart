import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import 'booking_service.dart';

class RatingGuardService {
  final BookingService bookingService =
  BookingService();

  // =========================
  // CHECK UNRATED COMPLETED TRIP
  // =========================

  Future<bool>
  hasCompletedUnratedBooking() async {
    final List<Map<String, dynamic>>
    bookings =
    await bookingService.getMyBookings();

    return bookings.any((booking) {
      final String status =
          booking['status']
              ?.toString() ??
              '';

      final bool isRated =
          booking['isRated'] == true;

      return status == 'completed' &&
          !isRated;
    });
  }

  // =========================
  // USER DESTINATION
  // =========================

  Future<void>
  openCorrectUserScreen() async {
    try {
      final bool ratingRequired =
      await hasCompletedUnratedBooking();

      if (ratingRequired) {
        Get.offAllNamed(
          AppRoutes.requiredRating,
        );
      } else {
        Get.offAllNamed(
          AppRoutes.home,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Connection Error',
        'Trip rating check نہیں ہوسکی۔ '
            'دوبارہ کوشش کریں۔',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration:
        const Duration(seconds: 5),
      );

      // Check fail ہونے پر Home bypass نہیں ہوگا
      Get.offAllNamed(
        AppRoutes.requiredRating,
      );
    }
  }
}