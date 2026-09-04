import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ambulance_controller.dart';

class AmbulanceView extends GetView<AmbulanceController> {
  const AmbulanceView({super.key});

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;

      case 'booked':
        return Colors.orange;

      case 'busy':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';

      case 'booked':
        return 'Booked';

      case 'busy':
        return 'Busy';

      default:
        return 'Offline';
    }
  }

  Widget informationRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text(
          'Ambulances',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  ElevatedButton.icon(
                    onPressed: controller.loadAmbulances,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.ambulances.isEmpty) {
          return const Center(
            child: Text('کوئی Ambulance موجود نہیں'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAmbulances,
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: controller.ambulances.length,
            itemBuilder: (context, index) {
              final ambulance = controller.ambulances[index];

              final bool isAvailable =
                  ambulance.status.toLowerCase() == 'available';

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          color: const Color(0xFFF1F3F5),
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            ambulance.ambulanceImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Center(
                                child: Icon(
                                  Icons.local_shipping,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(ambulance.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText(ambulance.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    ambulance.driverImage.isNotEmpty
                                        ? NetworkImage(
                                            ambulance.driverImage,
                                          )
                                        : null,
                                child: ambulance.driverImage.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 32,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            ambulance.driverName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (ambulance.isVerified)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                              size: 19,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      ambulance.ambulanceType,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (ambulance.rating > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '⭐ ${ambulance.rating.toStringAsFixed(1)} '
                                        '(${ambulance.ratingCount})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          informationRow(
                            Icons.confirmation_number_outlined,
                            'Vehicle: ${ambulance.vehicleNumber}',
                          ),
                          informationRow(
                            Icons.location_on_outlined,
                            ambulance.address,
                          ),
                          informationRow(
                            Icons.phone_outlined,
                            ambulance.driverPhone,
                          ),
                          if (ambulance.facilities.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: ambulance.facilities.map((facility) {
                                return Chip(
                                  visualDensity: VisualDensity.compact,
                                  avatar: const Icon(
                                    Icons.medical_services_outlined,
                                    size: 17,
                                    color: Colors.red,
                                  ),
                                  label: Text(facility),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                controller.rateAmbulance(
                                  ambulance.id,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber.shade800,
                                side: BorderSide(
                                  color: Colors.amber.shade700,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.star_outline),
                              label: const Text(
                                'Rate Service',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    controller.callDriver(
                                      ambulance.driverPhone,
                                    );
                                  },
                                  icon: const Icon(Icons.call),
                                  label: const Text('Call'),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    controller.openWhatsApp(
                                      ambulance.whatsappNumber,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.chat),
                                  label: const Text('WhatsApp'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    controller.openLocation(
                                      ambulance.latitude,
                                      ambulance.longitude,
                                    );
                                  },
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Location'),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isAvailable
                                      ? () {
                                          controller.bookAmbulance(
                                            ambulance.id,
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                  ),
                                  icon: const Icon(Icons.emergency),
                                  label: Text(
                                    isAvailable ? 'Book Now' : 'Already Booked',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
