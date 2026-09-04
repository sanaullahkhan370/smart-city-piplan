import 'dart:convert';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import '../../data/services/rating_guard_service.dart';

class HomeController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final RatingGuardService ratingGuardService = RatingGuardService();

  final RxBool isCheckingRating = false.obs;
  final RxString userName = 'User'.obs;
  final RxInt selectedIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final List<String> categories = const [
    'All',
    'Emergency',
    'Health',
    'Local Transport',
    'Travel',
    'Shopping',
  ];

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  @override
  void onReady() {
    super.onReady();
    checkRequiredRating();
  }

  Future<void> checkRequiredRating() async {
    if (isCheckingRating.value) return;

    try {
      isCheckingRating.value = true;
      final required = await ratingGuardService.hasCompletedUnratedBooking();
      if (required) Get.offAllNamed(AppRoutes.requiredRating);
    } catch (_) {
      Get.offAllNamed(AppRoutes.requiredRating);
    } finally {
      isCheckingRating.value = false;
    }
  }

  void loadUser() {
    final userJson = storage.readUser();
    if (userJson == null || userJson.isEmpty) return;

    try {
      final data = jsonDecode(userJson) as Map<String, dynamic>;
      userName.value = data['name']?.toString() ?? 'User';
    } catch (_) {
      userName.value = 'User';
    }
  }

  void updateSearch(String value) => searchQuery.value = value.trim().toLowerCase();
  void selectCategory(String value) => selectedCategory.value = value;

  void openVehicles({required String serviceType, required String title}) {
    Get.toNamed(
      AppRoutes.vehicles,
      arguments: {
        'serviceType': serviceType.trim().toLowerCase(),
        'title': title.trim(),
      },
    );
  }

  void openAmbulances() =>
      openVehicles(serviceType: 'ambulance', title: 'Ambulances');
  void openRickshaws() =>
      openVehicles(serviceType: 'rickshaw', title: 'Rickshaws');
  void openMazda() => openVehicles(serviceType: 'mazda', title: 'Mazda');
  void openPickups() =>
      openVehicles(serviceType: 'pickup', title: 'Pickups');

  void openHospitals() => Get.toNamed(
        AppRoutes.medical,
        arguments: {'section': 'hospitals'},
      );

  void openDoctors() => Get.toNamed(
        AppRoutes.medical,
        arguments: {'section': 'doctors'},
      );

  void openMedical() => Get.toNamed(AppRoutes.medical);
  void openMyBookings() => Get.toNamed(AppRoutes.myBookings);

  void openIntercityTransport() =>
      showComingSoon('Intercity Transport');
  void openShops() => showComingSoon('Shops & Market');
  void openEmergency() => showComingSoon('Emergency Services');
  void openNotifications() => showComingSoon('Notifications');
  void openProfile() => showComingSoon('Profile');

  void changeBottomPage(int index) {
    selectedIndex.value = index;
    if (index == 1) openNotifications();
    if (index == 2) openMyBookings();
    if (index == 3) openProfile();
  }

  void showComingSoon(String featureName) {
    Get.snackbar(
      featureName,
      '$featureName module will be connected soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
