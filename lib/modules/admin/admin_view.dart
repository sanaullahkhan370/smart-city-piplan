import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'booking_requests_section.dart';
import 'booking_requests_section.dart';
import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
        IconButton(
        onPressed: controller.refreshDashboard,
        tooltip: 'Refresh',
        icon: const Icon(Icons.refresh),
      ),
          IconButton(
            onPressed: controller.logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
            () => RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _adminHeader(),

              const SizedBox(height: 26),

              const BookingRequestsSection(),

              const SizedBox(height: 26),

              const Text(
                'My Ambulance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              if (controller.isLoading.value &&
                  controller.myAmbulance.value == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (controller.errorMessage.isNotEmpty)
                _errorCard()
              else if (controller.myAmbulance.value == null)
                  _noAmbulanceCard()
                else
                  _ambulanceCard(
                    controller.myAmbulance.value!,
                  ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ADMIN HEADER
  // =========================

  Widget _adminHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              color: Color(0xFF1565C0),
              size: 34,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${controller.adminName.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  controller.adminEmail.value,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ambulance Administrator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // AMBULANCE CARD
  // =========================

  Widget _ambulanceCard(
      Map<String, dynamic> ambulance,
      ) {
    final String imageUrl =
        ambulance['ambulanceImage']
            ?.toString() ??
            '';

    final String driverName =
        ambulance['driverName']?.toString() ??
            'Driver';

    final String vehicleNumber =
        ambulance['vehicleNumber']
            ?.toString() ??
            '';

    final String phone =
        ambulance['phone']?.toString() ?? '';

    final String address =
        ambulance['address']?.toString() ?? '';

    final String ambulanceType =
        ambulance['ambulanceType']
            ?.toString() ??
            '';

    final bool isOnline =
        ambulance['isOnline'] == true;

    final String status =
        ambulance['status']?.toString() ??
            'offline';

    final bool isVerified =
        ambulance['isVerified'] == true;

    final List<String> facilities =
    List<String>.from(
      ambulance['facilities'] ?? [],
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 230,
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return _imagePlaceholder();
              },
            )
                : _imagePlaceholder(),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicleNumber,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    if (isVerified)
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                          Colors.green.shade50,
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 17,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  ambulanceType,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const Divider(height: 30),

                _informationRow(
                  icon: Icons.person,
                  title: 'Driver',
                  value: driverName,
                ),

                _informationRow(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: phone,
                ),

                _informationRow(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: address,
                ),

                if (facilities.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facilities
                        .map(
                          (facility) => Chip(
                        avatar: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 17,
                        ),
                        label: Text(facility),
                      ),
                    )
                        .toList(),
                  ),
                ],

                const Divider(height: 34),

                _onlineSwitch(isOnline),

                const SizedBox(height: 16),

                _statusDropdown(
                  isOnline: isOnline,
                  status: status,
                ),

                if (controller.isUpdating.value) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],

                const SizedBox(height: 18),



                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                    controller.openAmbulances,
                    icon: const Icon(
                      Icons.remove_red_eye,
                    ),
                    label: const Text(
                      'View Public Ambulance Page',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ONLINE SWITCH
  // =========================

  Widget _onlineSwitch(bool isOnline) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isOnline
                ? Colors.green.shade50
                : Colors.red.shade50,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isOnline
                    ? Icons.wifi
                    : Icons.wifi_off,
                color: isOnline
                    ? Colors.green
                    : Colors.red,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline
                          ? 'Online'
                          : 'Offline',
                      style: TextStyle(
                        color: isOnline
                            ? Colors.green
                            : Colors.red,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      isOnline
                          ? 'Customers can see '
                          'your availability'
                          : 'Customers cannot see '
                          'this Ambulance',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (controller.isUpdating.value)
                const Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),

              Switch(
                value: isOnline,
                onChanged:
                controller.isUpdating.value
                    ? null
                    : controller
                    .changeOnlineStatus,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _liveLocationCard(isOnline),
      ],
    );
  }

  // =========================
// LIVE LOCATION CARD
// =========================

  Widget _liveLocationCard(bool isOnline) {
    final bool isSharing =
        controller.isSharingLocation.value;

    final String error =
        controller.locationError.value;

    final double latitude =
        controller.currentLatitude.value;

    final double longitude =
        controller.currentLongitude.value;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String title;
    String subtitle;

    if (!isOnline) {
      backgroundColor = Colors.grey.shade100;
      foregroundColor = Colors.grey;
      icon = Icons.location_off;
      title = 'Live Location Off';
      subtitle =
      'Ambulance Online کرنے پر tracking شروع ہوگی';
    } else if (isSharing) {
      backgroundColor = Colors.blue.shade50;
      foregroundColor =
      const Color(0xFF1565C0);
      icon = Icons.location_searching;
      title = 'Live Location Sharing';

      if (latitude != 0 && longitude != 0) {
        subtitle =
        '${latitude.toStringAsFixed(6)}, '
            '${longitude.toStringAsFixed(6)}';
      } else {
        subtitle =
        'Current GPS location حاصل کی جارہی ہے';
      }
    } else if (error.isNotEmpty) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red;
      icon = Icons.location_disabled;
      title = 'Location Error';
      subtitle = error;
    } else {
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange;
      icon = Icons.location_searching;
      title = 'Starting Live Location';
      subtitle =
      'GPS location حاصل کی جارہی ہے';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: foregroundColor.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foregroundColor,
            size: 28,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: foregroundColor
                        .withAlpha(190),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (isOnline && !isSharing)
            IconButton(
              onPressed:
              controller.retryLocationTracking,
              tooltip: 'Retry Location',
              icon: Icon(
                Icons.refresh,
                color: foregroundColor,
              ),
            ),

          if (isSharing)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // STATUS DROPDOWN
  // =========================

  Widget _statusDropdown({
    required bool isOnline,
    required String status,
  }) {
    return DropdownButtonFormField<String>(
      value: isOnline ? _validOnlineStatus(status) : 'offline',
      decoration: const InputDecoration(
        labelText: 'Ambulance Status',
        prefixIcon: Icon(Icons.emergency),
        border: OutlineInputBorder(),
      ),
      items: isOnline
          ? const [
              DropdownMenuItem(
                value: 'available',
                child: Text('Available'),
              ),
              DropdownMenuItem(
                value: 'booked',
                child: Text('Booked'),
              ),
              DropdownMenuItem(
                value: 'busy',
                child: Text('Busy'),
              ),
            ]
          : const [
              DropdownMenuItem(
                value: 'offline',
                child: Text('Offline'),
              ),
            ],
      onChanged: !isOnline || controller.isUpdating.value
          ? null
          : (val) {
              if (val != null) {
                controller.changeAmbulanceStatus(val);
              }
            },
    );
  }

  // =========================
  // EDIT DIALOG
  // =========================

  Future<void> _openEditDialog(
      Map<String, dynamic> ambulance,
      ) async {
    final driverNameController =
    TextEditingController(
      text:
      ambulance['driverName']?.toString() ??
          '',
    );

    final phoneController =
    TextEditingController(
      text: ambulance['phone']?.toString() ?? '',
    );

    final whatsappController =
    TextEditingController(
      text:
      ambulance['whatsappNumber']
          ?.toString() ??
          '',
    );

    final vehicleController =
    TextEditingController(
      text:
      ambulance['vehicleNumber']
          ?.toString() ??
          '',
    );

    final typeController =
    TextEditingController(
      text:
      ambulance['ambulanceType']
          ?.toString() ??
          '',
    );

    final addressController =
    TextEditingController(
      text:
      ambulance['address']?.toString() ??
          '',
    );

    final driverImageController =
    TextEditingController(
      text:
      ambulance['driverImage']
          ?.toString() ??
          '',
    );

    final ambulanceImageController =
    TextEditingController(
      text:
      ambulance['ambulanceImage']
          ?.toString() ??
          '',
    );

    final latitudeController =
    TextEditingController(
      text:
      ambulance['latitude']?.toString() ??
          '0',
    );

    final longitudeController =
    TextEditingController(
      text:
      ambulance['longitude']?.toString() ??
          '0',
    );

    final facilitiesController =
    TextEditingController(
      text: List<String>.from(
        ambulance['facilities'] ?? [],
      ).join(', '),
    );

    await Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit),
            SizedBox(width: 10),
            Text('Edit Ambulance'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField(
                  controller:
                  driverNameController,
                  label: 'Driver Name',
                  icon: Icons.person,
                ),

                _editField(
                  controller: phoneController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType:
                  TextInputType.phone,
                ),

                _editField(
                  controller:
                  whatsappController,
                  label: 'WhatsApp Number',
                  icon: Icons.chat,
                  keyboardType:
                  TextInputType.phone,
                ),

                _editField(
                  controller:
                  vehicleController,
                  label: 'Vehicle Number',
                  icon:
                  Icons.confirmation_number,
                ),

                _editField(
                  controller: typeController,
                  label: 'Ambulance Type',
                  icon: Icons.local_hospital,
                ),

                _editField(
                  controller:
                  addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),

                _editField(
                  controller:
                  latitudeController,
                  label: 'Latitude',
                  icon: Icons.map,
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                ),

                _editField(
                  controller:
                  longitudeController,
                  label: 'Longitude',
                  icon: Icons.map_outlined,
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                ),

                _editField(
                  controller:
                  driverImageController,
                  label: 'Driver Image URL',
                  icon: Icons.image,
                ),

                _editField(
                  controller:
                  ambulanceImageController,
                  label:
                  'Ambulance Image URL',
                  icon: Icons.image_outlined,
                ),

                _editField(
                  controller:
                  facilitiesController,
                  label:
                  'Facilities (comma separated)',
                  icon:
                  Icons.medical_services,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),

          Obx(
                () => ElevatedButton.icon(
              onPressed:
              controller.isUpdating.value
                  ? null
                  : () async {
                if (driverNameController
                    .text
                    .trim()
                    .isEmpty ||
                    phoneController.text
                        .trim()
                        .isEmpty ||
                    vehicleController.text
                        .trim()
                        .isEmpty) {
                  Get.snackbar(
                    'Required Fields',
                    'Driver name, phone and vehicle number are required',
                  );
                  return;
                }

                final bool success =
                await _saveAmbulanceDetails(
                  ambulanceId:
                  ambulance['_id']
                      .toString(),
                  data: {
                    'driverName':
                    driverNameController
                        .text
                        .trim(),
                    'phone':
                    phoneController.text
                        .trim(),
                    'whatsappNumber':
                    whatsappController
                        .text
                        .trim(),
                    'vehicleNumber':
                    vehicleController.text
                        .trim(),
                    'ambulanceType':
                    typeController.text
                        .trim(),
                    'address':
                    addressController.text
                        .trim(),
                    'latitude':
                    double.tryParse(
                      latitudeController
                          .text
                          .trim(),
                    ) ??
                        0,
                    'longitude':
                    double.tryParse(
                      longitudeController
                          .text
                          .trim(),
                    ) ??
                        0,
                    'driverImage':
                    driverImageController
                        .text
                        .trim(),
                    'ambulanceImage':
                    ambulanceImageController
                        .text
                        .trim(),
                    'facilities':
                    facilitiesController
                        .text
                        .split(',')
                        .map(
                          (item) =>
                          item.trim(),
                    )
                        .where(
                          (item) =>
                      item.isNotEmpty,
                    )
                        .toList(),
                  },
                );

                if (success) {
                  Get.back();
                }
              },
              icon: controller.isUpdating.value
                  ? const SizedBox(
                width: 17,
                height: 17,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    driverNameController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    vehicleController.dispose();
    typeController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    driverImageController.dispose();
    ambulanceImageController.dispose();
    facilitiesController.dispose();
  }

  // =========================
  // SAVE EDITED INFORMATION
  // =========================

  Future<bool> _saveAmbulanceDetails({
    required String ambulanceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      controller.isUpdating.value = true;

      final token = controller.storage.readToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token is missing',
        );
      }

      final response = await controller.api.patch(
        '${AdminController.baseUrl}'
            '/api/ambulances/$ambulanceId',
        data,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final body = response.body;

      if (response.statusCode == 200 &&
          body is Map &&
          body['success'] == true) {
        await controller.loadMyAmbulance();

        Get.snackbar(
          'Success',
          'Ambulance details updated successfully',
        );

        return true;
      }

      Get.snackbar(
        'Update Failed',
        body is Map
            ? body['message']?.toString() ??
            'Unable to update ambulance'
            : 'Unable to update ambulance',
      );

      return false;
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
      );

      return false;
    } finally {
      controller.isUpdating.value = false;
    }
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  String _validOnlineStatus(String status) {
    const allowedStatuses = [
      'available',
      'booked',
      'busy',
    ];

    if (allowedStatuses.contains(status)) {
      return status;
    }

    return 'available';
  }

  Widget _informationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: const Color(0xFF1565C0),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 70,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? 'Not provided'
                  : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.red.shade50,
      child: const Center(
        child: Icon(
          Icons.local_hospital,
          color: Colors.red,
          size: 80,
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 45,
            ),

            const SizedBox(height: 10),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed:
              controller.loadMyAmbulance,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noAmbulanceCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Column(
          children: [
            Icon(
              Icons.local_hospital_outlined,
              color: Colors.grey,
              size: 60,
            ),
            SizedBox(height: 12),
            Text(
              'No Ambulance Assigned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Please contact Super Admin',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}