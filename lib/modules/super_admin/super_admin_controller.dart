import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';

class SuperAdminController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final GetConnect api = GetConnect();

  final RxList<Map<String, dynamic>> admins =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> changeRequests =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  static const String baseUrl = 'http://localhost:5000';

  final List<String> adminServices = const [
    'ambulance',
    'rickshaw',
    'mazda',
    'pickup',
    'hospital',
    'doctor',
    'shop',
    'transport',
  ];

  int get totalAdmins => admins.length;

  int get pendingRequestsCount =>
      changeRequests.where((req) => req['status'] == 'pending').length;

  int get activeAdmins {
    return admins
        .where((admin) => admin['isActive'] == true)
        .length;
  }

  int get inactiveAdmins {
    return admins
        .where((admin) => admin['isActive'] == false)
        .length;
  }

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    await loadAdmins();
    await loadChangeRequests();
  }

  Future<void> loadChangeRequests() async {
    try {
      final token = storage.readToken();
      if (token == null || token.isEmpty) return;

      final response = await api.get(
        '$baseUrl/api/ambulance-change-requests',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        final List<dynamic> data = response.body['data'] ?? [];
        changeRequests.assignAll(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
      }
    } catch (error) {
      print('Error loading requests: $error');
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();
      final response = await api.patch(
        '$baseUrl/api/ambulance-change-requests/$requestId/approve',
        {},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Request approved');
        await refreshData();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to approve');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();
      final response = await api.patch(
        '$baseUrl/api/ambulance-change-requests/$requestId/reject',
        {'rejectionReason': reason},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Request rejected');
        await refreshData();
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to reject');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> loadAdmins() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = storage.readToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing');
      }

      final response = await api.get(
        '$baseUrl/api/admins',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 &&
          response.body['success'] == true) {
        final List<dynamic> data =
            response.body['data'] ?? [];

        admins.assignAll(
          data.map(
                (item) => Map<String, dynamic>.from(item),
          ),
        );
      } else {
        errorMessage.value =
            response.body?['message'] ??
                'Unable to load admins';
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String adminService,
  }) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();

      final response = await api.post(
        '$baseUrl/api/admins',
        {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'adminService': adminService,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201 &&
          response.body['success'] == true) {
        Get.snackbar('Success', 'Admin created successfully');
        await loadAdmins();
        return true;
      }

      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Admin could not be created',
      );
      return false;
    } catch (error) {
      Get.snackbar('Error', error.toString());
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> updateAdminStatus(
    String adminId,
    bool isActive,
  ) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();

      final response = await api.patch(
        '$baseUrl/api/admins/$adminId/status',
        {'isActive': isActive},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 &&
          response.body['success'] == true) {
        await loadAdmins();
        Get.snackbar(
          'Success',
          isActive ? 'Admin activated' : 'Admin deactivated',
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Status could not be updated',
        );
      }
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}