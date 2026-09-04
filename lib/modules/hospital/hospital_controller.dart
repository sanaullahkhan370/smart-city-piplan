import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/storage/storage_service.dart';

class HospitalController extends GetxController {
  final GetConnect api = GetConnect();
  final StorageService storage = Get.find<StorageService>();
  final facilities = <Map<String, dynamic>>[].obs;
  final filteredFacilities = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedType = 'all'.obs;
  final searchText = ''.obs;

  static const baseUrl = 'http://localhost:5000';

  @override
  void onInit() {
    super.onInit();
    loadFacilities();
  }

  Future<void> loadFacilities() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await api.get('$baseUrl/api/medical-facilities');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final data = List<dynamic>.from(response.body['data'] ?? []);
        facilities.assignAll(data.map((item) => Map<String, dynamic>.from(item)));
        applyFilters();
      } else {
        errorMessage.value =
            response.body?['message'] ?? 'Hospitals could not be loaded';
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  void search(String value) {
    searchText.value = value.trim().toLowerCase();
    applyFilters();
  }

  void applyFilters() {
    final query = searchText.value;
    filteredFacilities.assignAll(facilities.where((facility) {
      if (selectedType.value != 'all' &&
          facility['facilityType']?.toString() != selectedType.value) {
        return false;
      }
      if (query.isEmpty) return true;
      final doctors = List<dynamic>.from(facility['doctors'] ?? []);
      return (facility['name']?.toString().toLowerCase().contains(query) ?? false) ||
          (facility['address']?.toString().toLowerCase().contains(query) ?? false) ||
          doctors.any((doctor) {
            final item = Map<String, dynamic>.from(doctor);
            return (item['name']?.toString().toLowerCase().contains(query) ?? false) ||
                (item['specialist']?.toString().toLowerCase().contains(query) ?? false);
          });
    }));
  }


  Future<Map<String, dynamic>?> loadQueueStatus(
    String facilityId,
    String doctorId,
  ) async {
    try {
      final response = await api.get(
        '$baseUrl/api/doctor-queue/public/$facilityId/$doctorId',
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        return Map<String, dynamic>.from(response.body['data']);
      }
      Get.snackbar(
        'Queue unavailable',
        response.body?['message'] ?? 'Unable to load doctor queue',
      );
      return null;
    } catch (error) {
      Get.snackbar('Queue Error', error.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> takeToken(
    String facilityId,
    String doctorId,
  ) async {
    try {
      final token = storage.readToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Login Required', 'Please login to get a doctor token');
        return null;
      }
      final response = await api.post(
        '$baseUrl/api/doctor-queue/tokens',
        {'facilityId': facilityId, 'doctorId': doctorId},
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = response.body;
      if ((response.statusCode == 201 || response.statusCode == 409) &&
          body is Map) {
        if (response.statusCode == 201 && body['success'] == true) {
          Get.snackbar('Token Confirmed', body['message'] ?? 'Token issued');
        } else {
          Get.snackbar('Existing Token', body['message'] ?? 'Token already exists');
        }
        return body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : null;
      }
      Get.snackbar(
        'Token Failed',
        body is Map ? body['message']?.toString() ?? 'Unable to get token' : 'Unable to get token',
      );
      return null;
    } catch (error) {
      Get.snackbar('Token Error', error.toString());
      return null;
    }
  }

  Future<void> call(String? number) async {
    final clean = number?.trim() ?? '';
    if (clean.isEmpty) {
      Get.snackbar('Number unavailable', 'Appointment number is not available');
      return;
    }
    final uri = Uri(scheme: 'tel', path: clean);
    if (!await launchUrl(uri)) {
      Get.snackbar('Unable to call', clean);
    }
  }

  Future<void> whatsapp(String? number) async {
    var clean = (number ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) clean = '92${clean.substring(1)}';
    if (clean.isEmpty) {
      Get.snackbar('WhatsApp unavailable', 'WhatsApp number is not available');
      return;
    }
    final uri = Uri.parse('https://wa.me/$clean');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Unable to open WhatsApp', clean);
    }
  }
}
