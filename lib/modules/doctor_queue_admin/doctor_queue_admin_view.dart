import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doctor_queue_admin_controller.dart';

class DoctorQueueAdminView extends GetView<DoctorQueueAdminController> {
  const DoctorQueueAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Doctor OPD Queue'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: controller.loadQueue, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: controller.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.facilities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty && controller.facilities.isEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.facilities.isEmpty) {
          return const Center(
            child: Text('No hospital or clinic assigned to this admin'),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadQueue,
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _summary(),
              const SizedBox(height: 14),
              ...controller.facilities.map(_facility),
            ],
          ),
        );
      }),
    );
  }

  Widget _summary() {
    final waiting = controller.appointments
        .where((item) => item['status'] == 'waiting')
        .length;
    final active = controller.appointments
        .where((item) => item['status'] == 'inConsultation')
        .length;
    return Row(
      children: [
        Expanded(child: _stat('Waiting', waiting, Icons.people, Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _stat('In Consultation', active, Icons.medical_services, Colors.green)),
      ],
    );
  }

  Widget _stat(String title, int value, IconData icon, Color color) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: .15), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(title),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _facility(Map<String, dynamic> facility) {
    final doctors = List<dynamic>.from(facility['doctors'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          facility['name']?.toString() ?? 'Hospital / Clinic',
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        Text(facility['address']?.toString() ?? ''),
        const SizedBox(height: 10),
        if (doctors.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No doctors added')))
        else
          ...doctors.map((item) => _doctor(
                facility,
                Map<String, dynamic>.from(item),
              )),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _doctor(
    Map<String, dynamic> facility,
    Map<String, dynamic> doctor,
  ) {
    final facilityId = facility['_id']?.toString() ?? '';
    final doctorId = doctor['_id']?.toString() ?? '';
    final queue = controller.queueFor(doctorId);
    final current = doctor['currentToken'] ?? 0;
    final status = doctor['arrivalStatus']?.toString() ?? 'notArrived';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: status == 'arrived' ? Colors.green.shade100 : Colors.orange.shade100,
          child: const Icon(Icons.person),
        ),
        title: Text(
          doctor['name']?.toString() ?? 'Doctor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${doctor['specialist'] ?? ''} • Fee Rs. ${doctor['fee'] ?? 0}\n'
          'Current token: $current • Waiting: ${queue.where((x) => x['status'] == 'waiting').length}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          const Divider(),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(
              labelText: 'Doctor Arrival Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'notArrived', child: Text('Not Arrived')),
              DropdownMenuItem(value: 'arrived', child: Text('Doctor Arrived')),
              DropdownMenuItem(value: 'onBreak', child: Text('On Break')),
              DropdownMenuItem(value: 'finished', child: Text('OPD Finished')),
            ],
            onChanged: controller.isUpdating.value
                ? null
                : (value) {
                    if (value != null) {
                      controller.updateStatus(facilityId, doctorId, value);
                    }
                  },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isUpdating.value
                      ? null
                      : () => controller.callNext(facilityId, doctorId),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Call Next Token'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _editFee(facilityId, doctorId, doctor),
                icon: const Icon(Icons.edit),
                label: const Text('Fee'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Today’s Patients', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (queue.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tokens yet'),
            )
          else
            ...queue.map(_patient),
        ],
      ),
    );
  }

  Widget _patient(Map<String, dynamic> appointment) {
    final user = appointment['user'] is Map
        ? Map<String, dynamic>.from(appointment['user'])
        : <String, dynamic>{};
    final active = appointment['status'] == 'inConsultation';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: active ? Colors.green : Colors.blue.shade50,
        child: Text('${appointment['tokenNumber'] ?? '-'}'),
      ),
      title: Text(appointment['patientName']?.toString() ?? user['name']?.toString() ?? 'Patient'),
      subtitle: Text(appointment['phone']?.toString() ?? user['phone']?.toString() ?? ''),
      trailing: Text(active ? 'IN CONSULTATION' : 'WAITING',
          style: TextStyle(color: active ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
    );
  }

  void _editFee(
    String facilityId,
    String doctorId,
    Map<String, dynamic> doctor,
  ) {
    final fee = TextEditingController(text: doctor['fee']?.toString() ?? '0');
    final minutes = TextEditingController(
      text: doctor['averageConsultationMinutes']?.toString() ?? '15',
    );
    Get.dialog(
      AlertDialog(
        title: const Text('Update OPD Settings'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fee,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Consultation Fee',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Average minutes per patient',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final feeValue = double.tryParse(fee.text);
              final minuteValue = int.tryParse(minutes.text);
              if (feeValue == null || minuteValue == null) {
                Get.snackbar('Invalid', 'Enter valid fee and minutes');
                return;
              }
              Get.back();
              controller.updateFee(facilityId, doctorId, feeValue, minuteValue);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
