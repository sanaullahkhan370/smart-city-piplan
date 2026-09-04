import 'dart:convert';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import '../../data/services/rating_guard_service.dart';

class HomeController extends GetxController {
  final StorageService storage =
  Get.find<StorageService>();

  final RatingGuardService ratingGuardService =
  RatingGuardService();

  final RxBool isCheckingRating = false.obs;

  final RxString userName = 'User'.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    loadUser();
  }

  @override
  void onReady() {
    super.onReady();

    // Home دکھانے کے فوراً بعد check ہوگا
    // کہ کوئی completed unrated trip تو نہیں
    checkRequiredRating();
  }

  // ==================================
  // MANDATORY RATING CHECK
  // ==================================

  Future<void> checkRequiredRating() async {
    if (isCheckingRating.value) {
      return;
    }

    try {
      isCheckingRating.value = true;

      final bool ratingRequired =
      await ratingGuardService
          .hasCompletedUnratedBooking();

      if (ratingRequired) {
        Get.offAllNamed(
          AppRoutes.requiredRating,
        );
      }
    } catch (_) {
      // Rating verification fail ہو تو
      // Required Rating page کھلے گا
      Get.offAllNamed(
        AppRoutes.requiredRating,
      );
    } finally {
      isCheckingRating.value = false;
    }
  }

  // ==================================
  // LOAD USER INFORMATION
  // ==================================

  void loadUser() {
    final String? userJson =
    storage.readUser();

    if (userJson == null ||
        userJson.isEmpty) {
      userName.value = 'User';
      return;
    }

    try {
      final Map<String, dynamic> data =
      jsonDecode(userJson)
      as Map<String, dynamic>;

      userName.value =
          data['name']?.toString() ??
              'User';
    } catch (_) {
      userName.value = 'User';
    }
  }

  // ==================================
  // GENERIC VEHICLE NAVIGATION
  // ==================================

  void openVehicles({
    required String serviceType,
    required String title,
  }) {
    Get.toNamed(
      AppRoutes.vehicles,
      arguments: {
        'serviceType':
        serviceType.trim().toLowerCase(),
        'title': title.trim(),
      },
    );
  }

  // Ambulance card
  void openAmbulances() {
    openVehicles(
      serviceType: 'ambulance',
      title: 'Ambulances',
    );
  }

  // Rickshaw card
  void openRickshaws() {
    openVehicles(
      serviceType: 'rickshaw',
      title: 'Rickshaws',
    );
  }

  // Mazda card
  void openMazda() {
    openVehicles(
      serviceType: 'mazda',
      title: 'Mazda',
    );
  }

  // Pickup card
  void openPickups() {
    openVehicles(
      serviceType: 'pickup',
      title: 'Pickups',
    );
  }

  // Truck card
  void openTrucks() {
    openVehicles(
      serviceType: 'truck',
      title: 'Trucks',
    );
  }

  // ==================================
  // OTHER NAVIGATION
  // ==================================

  void openMedical() {
    Get.toNamed(
      AppRoutes.medical,
    );
  }

  void openMyBookings() {
    Get.toNamed(
      AppRoutes.myBookings,
    );
  }

  void openComplaints() {
    showComingSoon('Complaints');
  }

  void openBills() {
    showComingSoon('Bills');
  }

  void openServices() {
    showComingSoon('City Services');
  }

  void openAnnouncements() {
    showComingSoon('Announcements');
  }

  void openEmergency() {
    showComingSoon(
      'Emergency Services',
    );
  }

  void openProperty() {
    showComingSoon(
      'Property Information',
    );
  }

  // ==================================
  // BOTTOM NAVIGATION
  // ==================================

  void changeBottomPage(int index) {
    selectedIndex.value = index;

    if (index == 1) {
      showComingSoon(
        'Notifications',
      );
    } else if (index == 2) {
      showComingSoon(
        'Profile',
      );
    }
  }

  // ==================================
  // COMING SOON MESSAGE
  // ==================================

  void showComingSoon(
      String featureName,
      ) {
    Get.snackbar(
      featureName,
      '$featureName module will be added soon.',
      snackPosition:
      SnackPosition.BOTTOM,
      duration:
      const Duration(seconds: 2),
    );
  }

  // ==================================
  // LOGOUT
  // ==================================

  Future<void> logout() async {
    await storage.clearAll();

    Get.offAllNamed(
      AppRoutes.login,
    );
  }
}