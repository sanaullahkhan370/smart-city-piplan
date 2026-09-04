import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'vehicle_controller.dart';
import 'vehicle_model.dart';

class VehicleView extends GetView<VehicleController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),

      appBar: AppBar(
        backgroundColor: _primaryColor(),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Obx(
              () => Text(
            controller.pageTitle.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshVehicles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Obx(
            () {
          if (controller.isLoading.value &&
              controller.vehicles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage.isNotEmpty &&
              controller.vehicles.isEmpty) {
            return _errorView();
          }

          if (controller.vehicles.isEmpty) {
            return _emptyView();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshVehicles,
            child: ListView.separated(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: controller.vehicles.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return _vehicleCard(
                  controller.vehicles[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==================================
  // VEHICLE CARD
  // ==================================

  Widget _vehicleCard(VehicleModel vehicle) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _vehicleImage(vehicle),
          _vehicleInformation(vehicle),
        ],
      ),
    );
  }

  // ==================================
  // VEHICLE IMAGE
  // ==================================

  Widget _vehicleImage(VehicleModel vehicle) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 230,
          child: vehicle.vehicleImage.isEmpty
              ? _imagePlaceholder()
              : Image.network(
            vehicle.vehicleImage,
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return _imagePlaceholder();
            },
          ),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: _statusBadge(vehicle),
        ),

        if (vehicle.isVerified)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.local_shipping_outlined,
          size: 75,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ==================================
  // VEHICLE INFORMATION
  // ==================================

  Widget _vehicleInformation(
      VehicleModel vehicle,
      ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _driverImage(vehicle),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.driverName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      vehicle.vehicleType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              _ratingBadge(vehicle),
            ],
          ),

          const SizedBox(height: 18),

          _informationRow(
            icon: Icons.confirmation_number_outlined,
            label:
            'Vehicle: ${vehicle.vehicleNumber}',
          ),

          const SizedBox(height: 10),

          _informationRow(
            icon: Icons.location_on_outlined,
            label: vehicle.address.isEmpty
                ? 'Address not available'
                : vehicle.address,
          ),

          const SizedBox(height: 10),

          _informationRow(
            icon: Icons.phone_outlined,
            label: vehicle.phone,
          ),

          if (!vehicle.isAmbulance &&
              vehicle.capacityKg > 0) ...[
            const SizedBox(height: 10),
            _informationRow(
              icon: Icons.scale_outlined,
              label:
              'Capacity: ${_capacityText(vehicle.capacityKg)} kg',
            ),
          ],

          if (vehicle.features.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 9),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vehicle.features.map(
                    (feature) {
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor()
                          .withOpacity(0.08),
                      border: Border.all(
                        color: _primaryColor()
                            .withOpacity(0.45),
                      ),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _featureIcon(vehicle),
                          size: 16,
                          color: _primaryColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(feature),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ],

          const SizedBox(height: 20),

          _actionButtons(vehicle),
        ],
      ),
    );
  }

  // ==================================
  // DRIVER IMAGE
  // ==================================

  Widget _driverImage(VehicleModel vehicle) {
    return CircleAvatar(
      radius: 29,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: vehicle.driverImage.isEmpty
            ? const Icon(
          Icons.person,
          size: 34,
          color: Colors.grey,
        )
            : Image.network(
          vehicle.driverImage,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Icon(
              Icons.person,
              size: 34,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }

  // ==================================
  // RATING BADGE
  // ==================================

  Widget _ratingBadge(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 18,
            color: Colors.amber,
          ),
          const SizedBox(width: 3),
          Text(
            '${vehicle.rating.toStringAsFixed(1)} '
                '(${vehicle.ratingCount})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================
  // STATUS BADGE
  // ==================================

  Widget _statusBadge(VehicleModel vehicle) {
    final Color color =
    _statusColor(vehicle.status);

    final String text = vehicle.status.isEmpty
        ? 'Offline'
        : vehicle.status.capitalizeFirst ??
        vehicle.status;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================================
  // ACTION BUTTONS
  // ==================================

  Widget _actionButtons(
      VehicleModel vehicle,
      ) {
    return Column(
      children: [
        // =================================
        // CALL AND WHATSAPP
        // =================================

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vehicle.phone.isEmpty
                    ? null
                    : () {
                  controller.callDriver(
                    vehicle.phone,
                  );
                },
                icon: const Icon(
                  Icons.phone,
                ),
                label: const Text('Call'),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.openWhatsApp(
                    vehicle.whatsappNumber,
                    vehicle.phone,
                  );
                },
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF20C968),
                  foregroundColor:
                  Colors.white,
                ),
                icon: const Icon(
                  Icons.chat_outlined,
                ),
                label:
                const Text('WhatsApp'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =================================
        // LOCATION AND BOOKING
        // =================================

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vehicle.hasLocation
                    ? () {
                  controller.openLocation(
                    vehicle,
                  );
                }
                    : null,
                icon: const Icon(
                  Icons.location_on,
                ),
                label: const Text(
                  'Location',
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Obx(
                    () {
                  final bool isThisBooking =
                  controller
                      .isBookingVehicle(
                    vehicle.id,
                  );

                  final bool isAnyBooking =
                      controller
                          .bookingVehicleId
                          .value
                          .isNotEmpty;

                  final bool canBook =
                      vehicle.isAvailable &&
                          !isAnyBooking;

                  return ElevatedButton(
                    onPressed: canBook
                        ? () {
                      controller
                          .bookVehicle(
                        vehicle,
                      );
                    }
                        : null,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      vehicle.isAvailable
                          ? _primaryColor()
                          : Colors.grey,
                      foregroundColor:
                      Colors.white,
                      disabledBackgroundColor:
                      isThisBooking
                          ? _primaryColor()
                          .withAlpha(150)
                          : Colors.grey
                          .shade400,
                      disabledForegroundColor:
                      Colors.white,
                      minimumSize:
                      const Size.fromHeight(
                        42,
                      ),
                    ),
                    child: isThisBooking
                        ? const SizedBox(
                      width: 21,
                      height: 21,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Icon(
                          vehicle.isBooked
                              ? Icons.lock
                              : vehicle
                              .isAvailable
                              ? Icons
                              .event_available
                              : Icons
                              .block,
                          size: 19,
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Flexible(
                          child: Text(
                            vehicle.isBooked
                                ? 'Booked'
                                : vehicle
                                .isAvailable
                                ? 'Book Now'
                                : 'Unavailable',
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  // ==================================
  // EMPTY AND ERROR VIEWS
  // ==================================

  Widget _emptyView() {
    return RefreshIndicator(
      onRefresh: controller.refreshVehicles,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: Get.height * 0.7,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 75,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'No ${controller.pageTitle.value} available',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 65,
              color: Colors.red,
            ),
            const SizedBox(height: 14),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.loadVehicles,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================
  // HELPERS
  // ==================================

  Widget _informationRow({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  IconData _featureIcon(
      VehicleModel vehicle,
      ) {
    if (vehicle.isAmbulance) {
      return Icons.medical_services_outlined;
    }

    return Icons.check_circle_outline;
  }

  Color _primaryColor() {
    switch (controller.serviceType.value) {
      case 'ambulance':
        return Colors.red;

      case 'rickshaw':
        return Colors.orange.shade800;

      case 'mazda':
        return Colors.blue.shade700;

      case 'pickup':
        return Colors.teal;

      case 'truck':
        return Colors.indigo;

      default:
        return Colors.blue;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;

      case 'booked':
        return Colors.red;

      case 'busy':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  String _capacityText(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}