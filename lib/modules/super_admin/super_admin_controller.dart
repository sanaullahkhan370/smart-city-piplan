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
          'Content-Type': 'application/json',
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
          'Content-Type': 'application/json',
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
          'Content-Type': 'application/json',
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
          'Content-Type': 'application/json',
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

  void openCreateAdmin() {
    Get.snackbar(
      'Create Admin',
      'اب اگلے مرحلے میں Create Admin screen بنائیں گے',
    );
  }

  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}