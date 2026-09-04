import 'package:get/get.dart';

import '../../data/services/booking_service.dart';
import 'my_bookings_controller.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingService>()) {
      Get.lazyPut<BookingService>(
            () => BookingService(),
      );
    }

    Get.lazyPut<MyBookingsController>(
          () => MyBookingsController(),
    );
  }
}