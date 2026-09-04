import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hospital_controller.dart';

class HospitalView extends GetView<HospitalController> {
  const HospitalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Hospitals & Clinics'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.loadFacilities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  onChanged: controller.search,
                  decoration: InputDecoration(
                    hintText: 'Search hospital, clinic, doctor or specialist...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => Row(
                      children: [
                        _filter('All', 'all'),
                        _filter('Hospitals', 'hospital'),
                        _filter('Clinics', 'clinic'),
                      ],
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.isNotEmpty) {
                return _message(
                  Icons.error_outline,
                  controller.errorMessage.value,
                  controller.loadFacilities,
                );
              }
              if (controller.filteredFacilities.isEmpty) {
                return _message(
                  Icons.local_hospital_outlined,
                  'No hospital or clinic added yet',
                  controller.loadFacilities,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadFacilities,
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: controller.filteredFacilities.length,
                  itemBuilder: (_, index) =>
                      _facilityCard(controller.filteredFacilities[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filter(String label, String value) {
    final selected = controller.selectedType.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => controller.setType(value),
      ),
    );
  }

  Widget _facilityCard(Map<String, dynamic> facility) {
    final doctors = List<dynamic>.from(facility['doctors'] ?? []);
    final type = facility['facilityType']?.toString() ?? 'hospital';
    final cover = facility['coverImage']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: _image(
          cover,
          type == 'clinic' ? Icons.medical_services : Icons.local_hospital,
          58,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                facility['name']?.toString() ?? 'Medical Facility',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            if (facility['isVerified'] == true)
              const Icon(Icons.verified, color: Colors.blue, size: 20),
          ],
        ),
        subtitle: Text(
          '${type.capitalizeFirst} • ${doctors.length} doctor(s)\n'
          '${facility['address'] ?? ''}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          const Divider(),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _info(Icons.phone, 'Reception', facility['phone']),
              _info(Icons.emergency, 'Emergency', facility['emergencyNumber']),
              _info(Icons.schedule, 'Timing',
                  '${facility['openingTime'] ?? '-'} - ${facility['closingTime'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.call(facility['phone']?.toString()),
                icon: const Icon(Icons.call),
                label: const Text('Call Hospital'),
              ),
              const SizedBox(width: 8),
              if ((facility['whatsappNumber']?.toString() ?? '').isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.whatsapp(facility['whatsappNumber']?.toString()),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available Doctors',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          if (doctors.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Doctor information has not been added yet.'),
            )
          else
            ...doctors.map(
              (doctor) => _doctorCard(Map<String, dynamic>.from(doctor)),
            ),
        ],
      ),
    );
  }

  Widget _doctorCard(Map<String, dynamic> doctor) {
    final qualifications =
        List<dynamic>.from(doctor['qualifications'] ?? []).join(', ');
    final days = List<dynamic>.from(doctor['opdDays'] ?? []).join(', ');
    final available = doctor['isAvailable'] != false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image(doctor['photo']?.toString() ?? '', Icons.person, 66),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor['name']?.toString() ?? 'Doctor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(available ? 'Available' : 'Unavailable'),
                      backgroundColor:
                          available ? Colors.green.shade100 : Colors.red.shade100,
                    ),
                  ],
                ),
                Text(
                  doctor['specialist']?.toString() ?? 'General Physician',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (qualifications.isNotEmpty)
                  Text('Qualification: $qualifications'),
                Text('Fee: Rs. ${doctor['fee'] ?? 0}'),
                Text('Days: ${days.isEmpty ? '-' : days}'),
                Text(
                  'Time: ${doctor['startTime'] ?? '-'} - ${doctor['endTime'] ?? '-'}'
                  '${(doctor['roomNumber']?.toString() ?? '').isNotEmpty ? ' • Room ${doctor['roomNumber']}' : ''}',
                ),
                Text('Token: ${_pretty(doctor['tokenMethod'])}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: available
                          ? () => controller.call(
                              doctor['appointmentNumber']?.toString())
                          : null,
                      icon: const Icon(Icons.confirmation_number, size: 18),
                      label: Text(
                        'Get Number ${doctor['appointmentNumber'] ?? ''}',
                      ),
                    ),
                    if ((doctor['whatsappNumber']?.toString() ?? '').isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: available
                            ? () => controller.whatsapp(
                                doctor['whatsappNumber']?.toString())
                            : null,
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('WhatsApp'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String url, IconData fallback, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url.isEmpty
          ? Container(
              width: size,
              height: size,
              color: Colors.blue.shade50,
              child: Icon(fallback, color: Colors.blue),
            )
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: Colors.blue.shade50,
                child: Icon(fallback, color: Colors.blue),
              ),
            ),
    );
  }

  Widget _info(IconData icon, String label, dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Colors.blue),
        const SizedBox(width: 5),
        Text('$label: $text'),
      ],
    );
  }

  Widget _message(IconData icon, String text, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 55, color: Colors.grey),
          const SizedBox(height: 10),
          Text(text),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: retry, child: const Text('Refresh')),
        ],
      ),
    );
  }

  String _pretty(dynamic value) {
    final text = value?.toString().replaceAll('-', ' ') ?? 'Call';
    return text.isEmpty ? 'Call' : text[0].toUpperCase() + text.substring(1);
  }
}
