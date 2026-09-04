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
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            Icons.person,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          admin['name']?.toString() ?? 'Admin',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
        trailing: Switch(
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

  void _showCreateAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final selectedService = controller.adminServices.first.obs;
    final obscurePassword = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Create Service Admin'),
        content: SizedBox(
          width: 430,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => DropdownButtonFormField<String>(
                      value: selectedService.value,
                      decoration: const InputDecoration(
                        labelText: 'Admin Service',
                        prefixIcon: Icon(Icons.business_center_outlined),
                      ),
                      items: controller.adminServices
                          .map((service) => DropdownMenuItem(
                                value: service,
                                child: Text(
                                  service.capitalizeFirst ?? service,
                                                             ),
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
                        labelText: 'Password (minimum 8 characters)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => obscurePassword.toggle(),
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isProcessing.value
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty ||
                            passwordController.text.length < 8) {
                          Get.snackbar(
                            'Required',
                            'Complete all fields; password must be at least 8 characters',
                          );
                          return;
                        }

                        final created = await controller.createAdmin(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                          adminService: selectedService.value,
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
                label: const Text('Create Admin'),
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
