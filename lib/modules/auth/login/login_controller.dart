import 'dart:convert';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/rating_guard_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final StorageService storage =
  Get.find<StorageService>();

  final RatingGuardService ratingGuardService =
  RatingGuardService();

  final RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value =
    !isPasswordHidden.value;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        final token = response['token'];
        final user = response['user'];

        if (token != null) {
          await storage.writeToken(
            token.toString(),
          );
        }

        if (user != null) {
          await storage.writeUser(
            jsonEncode(user),
          );
        }

        Get.snackbar(
          'Success',
          'Login successful',
        );

        final String role =
            user?['role']?.toString() ?? 'user';

        if (role == 'superAdmin') {
          Get.offAllNamed(
            AppRoutes.superAdminDashboard,
          );
        } else if (role == 'admin') {
          final service =
              user?['adminService']?.toString().toLowerCase() ?? '';
          Get.offAllNamed(
            service == 'doctor' || service == 'hospital'
                ? AppRoutes.doctorQueueAdmin
                : AppRoutes.adminDashboard,
          );
        } else {
          // عام User کے لیے پہلے لازمی
          // completed trip rating check ہوگی
          await ratingGuardService
              .openCorrectUserScreen();
        }
      } else {
        Get.snackbar(
          'Login Failed',
          response['message'] ??
              'Invalid email or password',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    }
  }
}