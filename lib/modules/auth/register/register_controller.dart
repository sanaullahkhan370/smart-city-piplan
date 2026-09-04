import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService authService =
  Get.find<AuthService>();

  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value =
    !isPasswordHidden.value;
  }

  String? validateName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Name درج کریں';
    }

    if (name.length < 2) {
      return 'Name کم از کم 2 حروف کا ہونا چاہیے';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email درج کریں';
    }

    if (!GetUtils.isEmail(email)) {
      return 'درست Email درج کریں';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final String phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number درج کریں';
    }

    if (phone.length < 10 ||
        phone.length > 13) {
      return 'درست Phone number درج کریں';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Password درج کریں';
    }

    if (password.length < 6) {
      return 'Password کم از کم 6 حروف کا ہونا چاہیے';
    }

    return null;
  }

  Future<void> register() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> response =
      await authService.register(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Registration successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'Registration Failed',
          response['message']?.toString() ??
              'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}