import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class MedicalController extends GetxController {
  void openAmbulance() {
    Get.toNamed(AppRoutes.ambulance);
  }

  void openHospital() {
    Get.toNamed(AppRoutes.hospitals);
  }

  void openPharmacy() {
    Get.snackbar(
      'Pharmacy',
      'Pharmacy information will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}