import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';

class DoctorQueueAdminController extends GetxController {
  final GetConnect api = GetConnect();
  final StorageService storage = Get.find<StorageService>();
  final facilities = <Map<String, dynamic>>[].obs;
  final appointments = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = ''.obs;

  static const baseUrl = 'http://localhost:5000';

  @override
  void onInit() {
    super.onInit();
    loadQueue();
  }

  Map<String, String> get headers => {
        'Authorization': 'Bearer ${storage.readToken() ?? ''}',
      };

  Future<void> loadQueue() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await api.get(
        '$baseUrl/api/doctor-queue/admin',
        headers: headers,
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = Map<String, dynamic>.from(response.body['data']);
        facilities.assignAll(
          List<dynamic>.from(data['facilities'] ?? [])
              .map((item) => Map<String, dynamic>.from(item)),
        );
        appointments.assignAll(
          List<dynamic>.from(data['appointments'] ?? [])
              .map((item) => Map<String, dynamic>.from(item)),
        );
      } else {
        errorMessage.value =
            response.body?['message'] ?? 'Unable to load doctor queue';
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> queueFor(String doctorId) {
    return appointments
        .where((item) => item['doctorId']?.toString() == doctorId)
        .toList();
  }

  Future<void> updateStatus(
    String facilityId,
    String doctorId,
    String status,
  ) async {
    await _patch(
      '/api/doctor-queue/admin/status',
      {
        'facilityId': facilityId,
        'doctorId': doctorId,
        'arrivalStatus': status,
      },
      'Doctor status updated',
    );
  }

  Future<void> updateFee(
    String facilityId,
    String doctorId,
    double fee,
    int minutes,
  ) async {
    await _patch(
      '/api/doctor-queue/admin/fee',
      {
        'facilityId': facilityId,
        'doctorId': doctorId,
        'fee': fee,
        'averageConsultationMinutes': minutes,
      },
      'Fee and average consultation time updated',
    );
  }

  Future<void> callNext(String facilityId, String doctorId) async {
    await _patch(
      '/api/doctor-queue/admin/next',
      {'facilityId': facilityId, 'doctorId': doctorId},
      'Next patient called',
    );
  }

  Future<void> _patch(
    String path,
    Map<String, dynamic> body,
    String successMessage,
  ) async {
    try {
      isUpdating.value = true;
      final response = await api.patch(
        '$baseUrl$path',
        body,
        headers: headers,
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        Get.snackbar('Success', response.body['message'] ?? successMessage);
        await loadQueue();
      } else {
        Get.snackbar(
          'Update Failed',
          response.body?['message'] ?? 'Unable to update queue',
        );
      }
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    await storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
