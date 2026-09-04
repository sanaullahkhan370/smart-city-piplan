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

  final RxList<Map<String, dynamic>> medicalFacilities =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final Rxn<Map<String, dynamic>> selectedAdminDetails =
      Rxn<Map<String, dynamic>>();
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
    await loadMedicalFacilities();
    await loadChangeRequests();
  }


  Future<void> loadMedicalFacilities() async {
    try {
      final response = await api.get('$baseUrl/api/medical-facilities');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = List<dynamic>.from(response.body['data'] ?? []);
        medicalFacilities.assignAll(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
      }
    } catch (_) {
      medicalFacilities.clear();
    }
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
    String? facilityId,
    Map<String, dynamic>? doctorProfile,
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
          if (facilityId != null) 'facilityId': facilityId,
          if (doctorProfile != null) 'doctorProfile': doctorProfile,
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

  bool supportsVehicle(String? service) {
    return const {'rickshaw', 'mazda', 'pickup'}
        .contains(service?.toLowerCase());
  }

  Future<bool> assignVehicle({
    required String ownerId,
    required String serviceType,
    required String driverName,
    required String phone,
    required String whatsappNumber,
    required String driverImage,
    required String vehicleImage,
    required String vehicleNumber,
    required String vehicleType,
    required String address,
    required double capacityKg,
    required List<String> features,
  }) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();

      final response = await api.post(
        '$baseUrl/api/vehicles',
        {
          'owner': ownerId,
          'serviceType': serviceType.toLowerCase(),
          'driverName': driverName.trim(),
          'phone': phone.trim(),
          'whatsappNumber': whatsappNumber.trim(),
          'driverImage': driverImage.trim(),
          'vehicleImage': vehicleImage.trim(),
          'vehicleNumber': vehicleNumber.trim(),
          'vehicleType': vehicleType.trim(),
          'address': address.trim(),
          'capacityKg': capacityKg,
          'features': features,
          'isVerified': true,
          'isOnline': true,
          'status': 'available',
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201 &&
          response.body['success'] == true) {
        Get.snackbar(
          'Vehicle Assigned',
          '$serviceType vehicle assigned successfully',
        );
        return true;
      }

      Get.snackbar(
        'Assignment Failed',
        response.body?['message'] ?? 'Vehicle could not be assigned',
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


  Future<Map<String, dynamic>?> loadAdminDetails(String adminId) async {
    try {
      isDetailsLoading.value = true;
      selectedAdminDetails.value = null;
      final token = storage.readToken();
      final response = await api.get(
        '$baseUrl/api/admins/$adminId',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        final details = Map<String, dynamic>.from(response.body['data']);
        selectedAdminDetails.value = details;
        return details;
      }

      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Admin details could not be loaded',
      );
      return null;
    } catch (error) {
      Get.snackbar('Error', error.toString());
      return null;
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<bool> updateAdmin({
    required String adminId,
    required String name,
    required String email,
    required String phone,
    required String adminService,
    required bool isActive,
    String password = '',
  }) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();
      final body = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'adminService': adminService,
        'isActive': isActive,
      };
      if (password.trim().isNotEmpty) body['password'] = password;

      final response = await api.patch(
        '$baseUrl/api/admins/$adminId',
        body,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        await loadAdmins();
        await loadAdminDetails(adminId);
        Get.snackbar('Success', 'Admin updated successfully');
        return true;
      }

      Get.snackbar(
        'Update Failed',
        response.body?['message'] ?? 'Admin could not be updated',
      );
      return false;
    } catch (error) {
      Get.snackbar('Error', error.toString());
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    try {
      isProcessing.value = true;
      final token = storage.readToken();
      final response = await api.delete(
        '$baseUrl/api/admins/$adminId',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        selectedAdminDetails.value = null;
        await loadAdmins();
        Get.snackbar('Deleted', 'Admin deleted successfully');
        return true;
      }

      Get.snackbar(
        'Delete Blocked',
        response.body?['message'] ?? 'Admin could not be deleted',
        duration: const Duration(seconds: 5),
      );
      return false;
    } catch (error) {
      Get.snackbar('Error', error.toString());
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}