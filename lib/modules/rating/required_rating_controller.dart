import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/services/booking_service.dart';

class RequiredRatingController
    extends GetxController {
  final BookingService bookingService =
  Get.find<BookingService>();

  final Rxn<Map<String, dynamic>>
  requiredBooking =
  Rxn<Map<String, dynamic>>();

  final RxInt selectedRating = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRequiredRating();
  }

  Future<void> loadRequiredRating() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<Map<String, dynamic>>
      bookings =
      await bookingService.getMyBookings();

      Map<String, dynamic>? unratedBooking;

      for (final booking in bookings) {
        final String status =
            booking['status']
                ?.toString() ??
                '';

        final bool isRated =
            booking['isRated'] == true;

        if (status == 'completed' &&
            !isRated) {
          unratedBooking = booking;
          break;
        }
      }

      if (unratedBooking == null) {
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      requiredBooking.value =
          unratedBooking;
    } catch (error) {
      errorMessage.value =
          _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  void selectRating(int rating) {
    if (rating < 1 ||
        rating > 5 ||
        isSubmitting.value) {
      return;
    }

    selectedRating.value = rating;
  }

  Future<void> submitRating() async {
    final Map<String, dynamic>? booking =
        requiredBooking.value;

    if (booking == null) return;

    if (selectedRating.value == 0) {
      Get.snackbar(
        'Rating Required',
        'آگے جانے کے لیے کم از کم '
            'ایک star منتخب کریں',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final String bookingId =
        booking['_id']?.toString() ?? '';

    if (bookingId.isEmpty) {
      Get.snackbar(
        'Rating Error',
        'Booking ID موجود نہیں',
      );
      return;
    }

    try {
      isSubmitting.value = true;

      await bookingService
          .rateCompletedBooking(
        bookingId: bookingId,
        rating: selectedRating.value,
      );

      Get.snackbar(
        'Thank You',
        'آپ کی rating محفوظ ہوگئی ہے',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // اگر ایک سے زیادہ unrated trips ہوں
      // تو اگلی trip دکھائی جائے گی۔
      final List<Map<String, dynamic>>
      bookings =
      await bookingService.getMyBookings();

      Map<String, dynamic>? nextUnrated;

      for (final item in bookings) {
        final String status =
            item['status']?.toString() ?? '';

        if (status == 'completed' &&
            item['isRated'] != true) {
          nextUnrated = item;
          break;
        }
      }

      if (nextUnrated != null) {
        requiredBooking.value =
            nextUnrated;
        selectedRating.value = 0;
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (error) {
      Get.snackbar(
        'Rating Error',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration:
        const Duration(seconds: 6),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }
}