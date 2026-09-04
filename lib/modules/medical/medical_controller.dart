import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class MedicalController extends GetxController {
  void openAmbulance() {
    Get.toNamed(
      AppRoutes.vehicles,
      arguments: {
        'serviceType': 'ambulance',
        'title': 'Ambulances',
      },
    );
  }

  void openHospital() {
    Get.snackbar(
      'Hospitals',
      'Hospital information will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openDoctor() {
    Get.snackbar(
      'Doctors',
      'Doctor information will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openPharmacy() {
    Get.snackbar(
      'Pharmacy',
      'Pharmacy information will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}