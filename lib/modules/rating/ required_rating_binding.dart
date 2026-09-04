import 'package:get/get.dart';

import '../../data/services/booking_service.dart';
import 'required_rating_controller.dart';

class RequiredRatingBinding
    extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingService>()) {
      Get.lazyPut<BookingService>(
            () => BookingService(),
      );
    }

    Get.lazyPut<RequiredRatingController>(
          () => RequiredRatingController(),
    );
  }
}