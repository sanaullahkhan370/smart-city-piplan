import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalController extends GetxController {
  final GetConnect api = GetConnect();
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
