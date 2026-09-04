import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'super_admin_controller.dart';

class SuperAdminView
    extends GetView<SuperAdminController> {
  const SuperAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.loadAdmins,
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAdminDialog,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Create Admin'),
      ),

      body: Obx(() {
        if (controller.isLoading.value &&
            controller.admins.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.admins.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 55,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadAdmins,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                  constraints.maxWidth >= 700
                      ? (constraints.maxWidth - 36) / 4
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _statCard(
                        width: cardWidth,
                        title: 'Total Admins',
                        value: controller.totalAdmins,
                        icon: Icons.admin_panel_settings,
                        color: Colors.blue,
                      ),
                      _statCard(
                        width: cardWidth,
                        title: 'Pending Requests',
                        value: controller.pendingRequestsCount,
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      _statCard(
                        width: cardWidth,
                        title: 'Active Admins',
                        value: controller.activeAdmins,
                        icon: Icons.verified_user,
                        color: Colors.green,
                      ),
                      _statCard(
                        width: cardWidth,
                        title: 'Inactive Admins',
                        value: controller.inactiveAdmins,
                        icon: Icons.person_off,
                        color: Colors.red,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // ==============================
              // PENDING CHANGE REQUESTS
              // ==============================
              if (controller.changeRequests
                  .any((req) => req['status'] == 'pending')) ...[
                const Text(
                  'Pending Change Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.changeRequests
                    .where((req) => req['status'] == 'pending')
                    .map((req) => _requestCard(req)),
                const SizedBox(height: 28),
              ],

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Administrators',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${controller.totalAdmins} Admins',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (controller.admins.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'کوئی Admin موجود نہیں',
                      ),
                    ),
                  ),
                )
              else
                ...controller.admins.map(
                      (admin) => _adminCard(admin),
                ),

              const SizedBox(height: 90),
            ],
          ),
        );
      }),
    );
  }

  Widget _statCard({
    required double width,
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withValues(
                  alpha: 0.12,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminCard(Map<String, dynamic> admin) {
    final bool isActive = admin['isActive'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _showAdminDetails(admin),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            Icons.person,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(

          admin['name']?.toString() ?? 'Admin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(admin['email']?.toString() ?? ''),
            if ((admin['phone']?.toString() ?? '').isNotEmpty)
              Text(admin['phone'].toString()),
            Text(
              (admin['adminService']?.toString() ?? 'general')
                  .replaceAll('_', ' ')
                  .capitalizeFirst ?? 'General',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.supportsVehicle(
              admin['adminService']?.toString(),
            ))
              IconButton(
                tooltip: 'Assign Vehicle',
                onPressed: () => _showAssignVehicleDialog(admin),
                icon: const Icon(
                  Icons.add_road,
                  color: Colors.blue,
                ),
              ),
            Switch(
              value: isActive,
              activeThumbColor: Colors.green,
              onChanged: controller.isProcessing.value
                  ? null
                  : (value) => controller.updateAdminStatus(
                        admin['_id']?.toString() ??
                            admin['id']?.toString() ??
                            '',
                        value,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> request) {
    final adminName = request['requestedBy']?['name'] ?? 'Unknown Admin';
    final ambulance = request['ambulance'] ?? {};
    final vehicleNumber = ambulance['vehicleNumber'] ?? 'N/A';
    final changes = Map<String, dynamic>.from(request['changes'] ?? {});

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Ambulance: $vehicleNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'By: $adminName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            ...changes.entries.map((entry) {
              final oldValue = ambulance[entry.key]?.toString() ?? 'Empty';
              final newValue = entry.value?.toString() ?? 'Empty';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: Text(oldValue,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13))),
                        const Icon(Icons.arrow_forward, size: 14),
                        Expanded(
                            child: Text(newValue,
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 13))),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showRejectDialog(request['_id']),
                  child: const Text('Reject',
                      style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.approveRequest(request['_id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showAdminDetails(Map<String, dynamic> selectedAdmin) {
    final adminId = selectedAdmin['_id']?.toString() ??
        selectedAdmin['id']?.toString() ?? '';
    controller.loadAdminDetails(adminId);

    Get.dialog(
      AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
        title: Row(
          children: [
            const Icon(Icons.manage_accounts, color: Colors.blue),
            const SizedBox(width: 10),
            const Expanded(child: Text('Administrator Details')),
            IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
          ],
        ),
        content: SizedBox(
          width: 850,
          height: 620,
          child: Obx(() {
            if (controller.isDetailsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final details = controller.selectedAdminDetails.value;
            if (details == null) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () => controller.loadAdminDetails(adminId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              );
            }

            final admin = Map<String, dynamic>.from(details['admin'] ?? {});
            final summary = Map<String, dynamic>.from(details['summary'] ?? {});
            final vehicles = List<dynamic>.from(details['vehicles'] ?? []);
            final ambulances = List<dynamic>.from(details['ambulances'] ?? []);
            final bookings = List<dynamic>.from(details['recentBookings'] ?? []);
            final assets = [...vehicles, ...ambulances];

            return ListView(
              children: [
                _adminProfile(admin),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _detailStat('Assets', summary['assignedAssets'], Icons.local_shipping, Colors.blue),
                    _detailStat('Bookings', summary['totalBookings'], Icons.receipt_long, Colors.indigo),
                    _detailStat('Active', summary['activeBookings'], Icons.notifications_active, Colors.orange),
                    _detailStat('Completed', summary['completedBookings'], Icons.check_circle, Colors.green),
                    _detailStat('Trips', summary['totalTrips'], Icons.route, Colors.teal),
                    _detailStat(
                      'Rating',
                      '${summary['rating'] ?? 0} (${summary['ratingCount'] ?? 0})',
                      Icons.star,
                      Colors.amber.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle('Assigned Service / Vehicle', Icons.directions_car),
                if (assets.isEmpty)
                  const _EmptyMessage('No vehicle or ambulance assigned')
                else
                  ...assets.map((item) => _assetCard(
                        Map<String, dynamic>.from(item),
                        isAmbulance: ambulances.contains(item),
                      )),
                const SizedBox(height: 22),
                _sectionTitle('Recent Pickup & Booking Details', Icons.location_on),
                if (bookings.isEmpty)
                  const _EmptyMessage('No booking history available')
                else
                  ...bookings.map((item) =>
                      _bookingCard(Map<String, dynamic>.from(item))),
              ],
            );
          }),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final details = controller.selectedAdminDetails.value;
              if (details != null) {
                _showEditAdminDialog(
                  Map<String, dynamic>.from(details['admin'] ?? {}),
                );
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _confirmDeleteAdmin(adminId),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
          ElevatedButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _adminProfile(Map<String, dynamic> admin) {
    final active = admin['isActive'] == true;
    return Card(
      color: const Color(0xFFEAF4FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: active ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(Icons.person, size: 34, color: active ? Colors.green : Colors.red),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(admin['name']?.toString() ?? 'Admin',
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  Text(admin['email']?.toString() ?? ''),
                  Text(admin['phone']?.toString() ?? 'No phone'),
                  Text(
                    '${_pretty(admin['adminService'])} Administrator',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(active ? 'Active' : 'Inactive'),
              backgroundColor: active ? Colors.green.shade100 : Colors.red.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailStat(String title, dynamic value, IconData icon, Color color) {
    return SizedBox(
      width: 126,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 5),
              Text(value?.toString() ?? '0',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _assetCard(Map<String, dynamic> asset, {required bool isAmbulance}) {
    final image = (isAmbulance ? asset['ambulanceImage'] : asset['vehicleImage'])
            ?.toString() ?? '';
    final driverImage = asset['driverImage']?.toString() ?? '';
    final features = List<dynamic>.from(
      (isAmbulance ? asset['facilities'] : asset['features']) ?? [],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _networkPicture(image, Icons.local_shipping),
            const SizedBox(width: 12),
            _networkPicture(driverImage, Icons.person, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 24,
                runSpacing: 6,
                children: [
                  _info('Driver', asset['driverName']),
                  _info('Number', asset['vehicleNumber']),
                  _info('Type', isAmbulance ? asset['ambulanceType'] : asset['vehicleType']),
                  _info('Phone', asset['phone']),
                  _info('WhatsApp', asset['whatsappNumber']),
                  _info('Address', asset['address']),
                  _info('Status', _pretty(asset['status'])),
                  _info('Online', asset['isOnline'] == true ? 'Yes' : 'No'),
                  _info('Verified', asset['isVerified'] == true ? 'Yes' : 'No'),
                  _info('Rating', '${asset['rating'] ?? 0} (${asset['ratingCount'] ?? 0})'),
                  _info('Trips', asset['totalTrips']),
                  if (!isAmbulance) _info('Capacity', '${asset['capacityKg'] ?? 0} KG'),
                  if (features.isNotEmpty) _info('Features', features.join(', ')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    final user = booking['user'] is Map
        ? Map<String, dynamic>.from(booking['user'])
        : <String, dynamic>{};
    final customer = booking['customerName']?.toString().isNotEmpty == true
        ? booking['customerName']
        : booking['patientName'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text((customer?.toString().isNotEmpty == true
                  ? customer.toString()[0]
                  : 'U').toUpperCase()),
        ),
        title: Text(customer?.toString().isNotEmpty == true
            ? customer.toString()
            : user['name']?.toString() ?? 'Customer'),
        subtitle: Text(
          'Phone: ${booking['phone'] ?? user['phone'] ?? '-'}\n'
          'Pickup: ${booking['pickupAddress'] ?? '-'}'
          '${(booking['notes']?.toString() ?? '').isNotEmpty ? '\nNotes: ${booking['notes']}' : ''}',
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(_pretty(booking['status'])),
          backgroundColor: _statusColor(booking['status']).withValues(alpha: .14),
          labelStyle: TextStyle(color: _statusColor(booking['status'])),
        ),
      ),
    );
  }

  Widget _networkPicture(String url, IconData fallback, {double size = 72}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url.isEmpty
          ? Container(
              width: size, height: size, color: Colors.grey.shade200,
              child: Icon(fallback, color: Colors.grey),
            )
          : Image.network(
              url, width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size, height: size, color: Colors.grey.shade200,
                child: Icon(fallback, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _info(String label, dynamic value) => SizedBox(
        width: 180,
        child: Text.rich(
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: value?.toString().isNotEmpty == true ? value.toString() : '-',
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      );

  String _pretty(dynamic value) {
    final text = value?.toString().replaceAll('_', ' ') ?? 'General';
    if (text.isEmpty) return 'General';
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _statusColor(dynamic status) {
    switch (status?.toString()) {
      case 'completed':
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'booked':
        return Colors.blue;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final id = admin['_id']?.toString() ?? admin['id']?.toString() ?? '';
    final name = TextEditingController(text: admin['name']?.toString() ?? '');
    final email = TextEditingController(text: admin['email']?.toString() ?? '');
    final phone = TextEditingController(text: admin['phone']?.toString() ?? '');
    final password = TextEditingController();
    final service = (admin['adminService']?.toString() ??
        controller.adminServices.first).obs;
    final active = (admin['isActive'] == true).obs;
    final hidePassword = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Administrator'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _vehicleField(name, 'Admin Name', Icons.person),
                _vehicleField(email, 'Email', Icons.email),
                _vehicleField(phone, 'Phone', Icons.phone),
                Obx(() => DropdownButtonFormField<String>(
                      value: service.value,
                      decoration: const InputDecoration(
                        labelText: 'Admin Service',
                        prefixIcon: Icon(Icons.business_center),
                        border: OutlineInputBorder(),
                      ),
                      items: controller.adminServices
                          .map((item) => DropdownMenuItem(
                                value: item, child: Text(_pretty(item))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) service.value = value;
                      },
                    )),
                const SizedBox(height: 12),
                Obx(() => TextField(
                      controller: password,
                      obscureText: hidePassword.value,
                      decoration: InputDecoration(
                        labelText: 'New Password (optional)',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: hidePassword.toggle,
                          icon: Icon(hidePassword.value
                              ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    )),
                Obx(() => SwitchListTile(
                      title: const Text('Admin Active'),
                      value: active.value,
                      onChanged: (value) => active.value = value,
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        if (name.text.trim().isEmpty ||
                            email.text.trim().isEmpty ||
                            phone.text.trim().isEmpty ||
                            (password.text.isNotEmpty && password.text.length < 8)) {
                          Get.snackbar('Required', 'Complete all fields; new password must be 8+ characters');
                          return;
                        }
                        final saved = await controller.updateAdmin(
                          adminId: id,
                          name: name.text,
                          email: email.text,
                          phone: phone.text,
                          adminService: service.value,
                          isActive: active.value,
                          password: password.text,
                        );
                        if (saved) Get.back();
                      },
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              )),
        ],
      ),
    );
  }

  void _confirmDeleteAdmin(String adminId) {
    Get.defaultDialog(
      title: 'Delete Administrator?',
      middleText:
          'Only an admin with no assigned service and no booking history can be deleted. Otherwise deactivate it to keep records safe.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        final deleted = await controller.deleteAdmin(adminId);
        if (deleted) {
          Get.back();
          Get.back();
        }
      },
    );
  }

  void _showAssignVehicleDialog(
    Map<String, dynamic> admin,
  ) {
    final service =
        admin['adminService']?.toString().toLowerCase() ?? 'mazda';
    final driverName = TextEditingController(
      text: admin['name']?.toString() ?? '',
    );
    final phone = TextEditingController(
      text: admin['phone']?.toString() ?? '',
    );
    final whatsapp = TextEditingController();
    final driverImage = TextEditingController();
    final vehicleImage = TextEditingController();
    final vehicleNumber = TextEditingController();
    final vehicleType = TextEditingController(
      text: service == 'mazda' ? 'Loader Mazda' : '',
    );
    final address = TextEditingController();
    final capacity = TextEditingController();
    final features = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Assign ${service.capitalizeFirst}'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _vehicleField(driverName, 'Driver/Admin Name', Icons.person),
                _vehicleField(phone, 'Phone', Icons.phone),
                _vehicleField(whatsapp, 'WhatsApp Number', Icons.chat),
                _vehicleField(vehicleNumber, 'Vehicle Number', Icons.numbers),
                _vehicleField(vehicleType, 'Vehicle Type', Icons.local_shipping),
                _vehicleField(driverImage, 'Admin/Driver Picture URL', Icons.person_pin),
                _vehicleField(vehicleImage, 'Vehicle Picture URL', Icons.image),
                _vehicleField(address, 'Address', Icons.location_on),
                _vehicleField(capacity, 'Capacity in KG', Icons.scale),
                _vehicleField(
                  features,
                  'Features (comma separated)',
                  Icons.list,
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
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        if (driverName.text.trim().isEmpty ||
                            phone.text.trim().isEmpty ||
                            vehicleNumber.text.trim().isEmpty ||
                            vehicleType.text.trim().isEmpty) {
                          Get.snackbar(
                            'Required',
                            'Name, phone, vehicle number and type are required',
                          );
                          return;
                        }

                        final success = await controller.assignVehicle(
                          ownerId: admin['_id']?.toString() ??
                              admin['id']?.toString() ??
                              '',
                          serviceType: service,
                          driverName: driverName.text,
                          phone: phone.text,
                          whatsappNumber: whatsapp.text,
                          driverImage: driverImage.text,
                          vehicleImage: vehicleImage.text,
                          vehicleNumber: vehicleNumber.text,
                          vehicleType: vehicleType.text,
                          address: address.text,
                          capacityKg:
                              double.tryParse(capacity.text.trim()) ?? 0,
                          features: features.text
                              .split(',')
                              .map((value) => value.trim())
                              .where((value) => value.isNotEmpty)
                              .toList(),
                        );

                        if (success) Get.back();
                      },
                icon: const Icon(Icons.save),
                label: const Text('Assign Vehicle'),
              )),
        ],
      ),
    );
  }

  Widget _vehicleField(
    TextEditingController fieldController,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: fieldController,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showCreateAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final specialist = TextEditingController();
    final qualifications = TextEditingController();
    final fee = TextEditingController();
    final opdDays = TextEditingController();
    final startTime = TextEditingController();
    final endTime = TextEditingController();
    final appointmentNumber = TextEditingController();
    final whatsapp = TextEditingController();
    final photo = TextEditingController();
    final room = TextEditingController();
    final averageMinutes = TextEditingController(text: '15');

    final selectedService = controller.adminServices.first.obs;
    final selectedFacility = (controller.medicalFacilities.isNotEmpty
            ? controller.medicalFacilities.first['_id']?.toString() ?? ''
            : '')
        .obs;
    final obscurePassword = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Service Admin'),
        content: SizedBox(
          width: 540,
          height: 650,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _vehicleField(nameController, 'Admin / Doctor Name', Icons.person),
                _vehicleField(emailController, 'Login Email', Icons.email),
                _vehicleField(phoneController, 'Phone', Icons.phone),
                Obx(() => DropdownButtonFormField<String>(
                      value: selectedService.value,
                      decoration: const InputDecoration(
                        labelText: 'Admin Service',
                        prefixIcon: Icon(Icons.business_center),
                        border: OutlineInputBorder(),
                      ),
                      items: controller.adminServices
                          .map((service) => DropdownMenuItem(
                                value: service,
                                child: Text(service.capitalizeFirst ?? service),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedService.value = value;
                      },
                    )),
                const SizedBox(height: 12),
                Obx(() => TextField(
                      controller: passwordController,
                      obscureText: obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Login Password (minimum 8 characters)',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: obscurePassword.toggle,
                          icon: Icon(obscurePassword.value
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    )),
                Obx(() {
                  if (selectedService.value != 'doctor') {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const Divider(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Doctor Profile & OPD Assignment',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (controller.medicalFacilities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.orange.shade50,
                          child: const Text(
                            'No hospital/clinic found. Run medical seed or create a facility first.',
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: selectedFacility.value.isEmpty
                              ? null
                              : selectedFacility.value,
                          decoration: const InputDecoration(
                            labelText: 'Hospital / Clinic',
                            prefixIcon: Icon(Icons.local_hospital),
                            border: OutlineInputBorder(),
                          ),
                          items: controller.medicalFacilities
                              .map((facility) => DropdownMenuItem<String>(
                                    value: facility['_id']?.toString(),
                                    child: Text(
                                      '${facility['name']} (${_pretty(facility['facilityType'])})',
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            selectedFacility.value = value ?? '';
                          },
                        ),
                      const SizedBox(height: 12),
                      _vehicleField(specialist, 'Specialist (e.g. Gynecologist)', Icons.medical_services),
                      _vehicleField(qualifications, 'Qualifications (MBBS, FCPS)', Icons.school),
                      _vehicleField(fee, 'Consultation Fee', Icons.payments),
                      _vehicleField(opdDays, 'OPD Days (Monday, Wednesday)', Icons.calendar_month),
                      _vehicleField(startTime, 'Start Time (04:00 PM)', Icons.schedule),
                      _vehicleField(endTime, 'End Time (08:00 PM)', Icons.schedule),
                      _vehicleField(appointmentNumber, 'Appointment / Token Number', Icons.confirmation_number),
                      _vehicleField(whatsapp, 'WhatsApp Number', Icons.chat),
                      _vehicleField(room, 'Room Number (optional)', Icons.meeting_room),
                      _vehicleField(averageMinutes, 'Average Minutes per Patient', Icons.timer),
                      _vehicleField(photo, 'Doctor Photo URL (optional)', Icons.image),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        final isDoctor = selectedService.value == 'doctor';
                        final baseInvalid = nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty ||
                            passwordController.text.length < 8;
                        final doctorInvalid = isDoctor &&
                            (selectedFacility.value.isEmpty ||
                                specialist.text.trim().isEmpty ||
                                qualifications.text.trim().isEmpty ||
                                fee.text.trim().isEmpty ||
                                opdDays.text.trim().isEmpty ||
                                startTime.text.trim().isEmpty ||
                                endTime.text.trim().isEmpty ||
                                appointmentNumber.text.trim().isEmpty);
                        if (baseInvalid || doctorInvalid) {
                          Get.snackbar(
                            'Required',
                            isDoctor
                                ? 'Complete login, hospital, specialist, qualification, fee, days, time and appointment number'
                                : 'Complete all login fields; password must be 8+ characters',
                          );
                          return;
                        }

                        final created = await controller.createAdmin(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                          adminService: selectedService.value,
                          facilityId: isDoctor ? selectedFacility.value : null,
                          doctorProfile: isDoctor
                              ? {
                                  'specialist': specialist.text.trim(),
                                  'qualifications': qualifications.text
                                      .split(',')
                                      .map((item) => item.trim())
                                      .where((item) => item.isNotEmpty)
                                      .toList(),
                                  'fee': double.tryParse(fee.text) ?? 0,
                                  'opdDays': opdDays.text
                                      .split(',')
                                      .map((item) => item.trim())
                                      .where((item) => item.isNotEmpty)
                                      .toList(),
                                  'startTime': startTime.text.trim(),
                                  'endTime': endTime.text.trim(),
                                  'appointmentNumber': appointmentNumber.text.trim(),
                                  'contactNumber': phoneController.text.trim(),
                                  'whatsappNumber': whatsapp.text.trim(),
                                  'roomNumber': room.text.trim(),
                                  'photo': photo.text.trim(),
                                  'tokenMethod': whatsapp.text.trim().isEmpty
                                      ? 'call'
                                      : 'whatsapp',
                                  'averageConsultationMinutes':
                                      int.tryParse(averageMinutes.text) ?? 15,
                                  'isAvailable': true,
                                }
                              : null,
                        );
                        if (created) Get.back();
                      },
                icon: controller.isProcessing.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add),
                label: Text(selectedService.value == 'doctor'
                    ? 'Create Doctor & Login'
                    : 'Create Admin'),
              )),
        ],
      ),
    );
  }

  void _showRejectDialog(String requestId) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Enter rejection reason'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                Get.snackbar('Error', 'Reason is required');
                return;
              }
              Get.back();
              controller.rejectRequest(requestId, reasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String text;
  const _EmptyMessage(this.text);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
      );
}
