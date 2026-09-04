import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_controller.dart';

class BookingRequestsSection
    extends GetView<AdminController> {
  const BookingRequestsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.orange,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Active Booking Requests',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (controller
                  .pendingBookings.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller
                        .pendingBookings.length
                        .toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (controller
              .isBookingsLoading.value)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child:
                  CircularProgressIndicator(),
                ),
              ),
            )
          else if (controller
              .bookingErrorMessage.isNotEmpty)
            _errorCard()
          else if (controller
                .pendingBookings.isEmpty)
              _emptyCard()
            else
              ...controller.pendingBookings.map(
                    (booking) => _bookingCard(
                  booking,
                ),
              ),
        ],
      );
    });
  }

  // =========================
  // BOOKING CARD
  // =========================

  Widget _bookingCard(
      Map<String, dynamic> booking,
      ) {
    final String bookingId =
        booking['_id']?.toString() ?? '';

    final String patientName =
        booking['patientName']
            ?.toString() ??
            'Patient';

    final String phone =
        booking['phone']?.toString() ?? '';

    final String pickupAddress =
        booking['pickupAddress']
            ?.toString() ??
            '';

    final String notes =
        booking['notes']?.toString() ?? '';

    final String status =
        booking['status']?.toString() ??
            'pending';

    final String createdAt =
        booking['createdAt']
            ?.toString() ??
            '';

    final String acceptedAt =
        booking['acceptedAt']
            ?.toString() ??
            '';

    final Map<String, dynamic> ambulance =
    booking['ambulance'] is Map
        ? Map<String, dynamic>.from(
      booking['ambulance'] as Map,
    )
        : <String, dynamic>{};

    final Map<String, dynamic> user =
    booking['user'] is Map
        ? Map<String, dynamic>.from(
      booking['user'] as Map,
    )
        : <String, dynamic>{};

    final String vehicleNumber =
        ambulance['vehicleNumber']
            ?.toString() ??
            '';

    final String userEmail =
        user['email']?.toString() ?? '';

    final bool isProcessing =
        controller.processingBookingId.value ==
            bookingId;

    final bool isAccepted =
        status == 'accepted';

    final Color statusColor =
    isAccepted
        ? Colors.green
        : Colors.orange;

    return Card(
      margin:
      const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  statusColor.withAlpha(30),
                  child: Icon(
                    isAccepted
                        ? Icons.local_hospital
                        : Icons.schedule,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        vehicleNumber.isEmpty
                            ? 'Ambulance booking'
                            : 'Ambulance: '
                            '$vehicleNumber',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                    statusColor.withAlpha(25),
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Text(
                    isAccepted
                        ? 'ACCEPTED'
                        : 'PENDING',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            _informationRow(
              icon: Icons.person,
              label: 'Patient',
              value: patientName,
            ),

            _informationRow(
              icon: Icons.phone,
              label: 'Phone',
              value: phone,
            ),

            if (userEmail.isNotEmpty)
              _informationRow(
                icon: Icons.email,
                label: 'Email',
                value: userEmail,
              ),

            if (createdAt.isNotEmpty)
              _informationRow(
                icon: Icons.access_time,
                label: 'Created',
                value:
                _formatDate(createdAt),
              ),

            if (acceptedAt.isNotEmpty)
              _informationRow(
                icon: Icons.check_circle,
                label: 'Accepted',
                value:
                _formatDate(acceptedAt),
              ),

            if (notes.isNotEmpty)
              _informationRow(
                icon: Icons.notes,
                label: 'Notes',
                value: notes,
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                pickupAddress.isEmpty
                    ? null
                    : () {
                  controller
                      .openPickupLocation(
                    pickupAddress,
                  );
                },
                icon: const Icon(
                  Icons.location_on,
                ),
                label: const Text(
                  'Open Patient Pickup Location',
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isProcessing)
              const LinearProgressIndicator()
            else if (status == 'pending')
              _pendingButtons(bookingId)
            else if (status == 'accepted')
                _completeButton(bookingId),
          ],
        ),
      ),
    );
  }

  // =========================
  // PENDING BUTTONS
  // =========================

  Widget _pendingButtons(
      String bookingId,
      ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              controller.rejectBooking(
                bookingId,
              );
            },
            style:
            OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(
                color: Colors.red,
              ),
            ),
            icon:
            const Icon(Icons.close),
            label:
            const Text('Reject'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              controller.acceptBooking(
                bookingId,
              );
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon:
            const Icon(Icons.check),
            label:
            const Text('Accept'),
          ),
        ),
      ],
    );
  }

  // =========================
  // COMPLETE BUTTON
  // =========================

  Widget _completeButton(
      String bookingId,
      ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_hospital,
                color: Colors.green,
              ),

              SizedBox(width: 9),

              Expanded(
                child: Text(
                  'Booking accepted — '
                      'Ambulance trip is active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.completeBooking(
                bookingId,
              );
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize:
              const Size.fromHeight(48),
            ),
            icon: const Icon(
              Icons.check_circle,
            ),
            label: const Text(
              'Complete Trip',
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // INFORMATION ROW
  // =========================

  Widget _informationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color:
            const Color(0xFF1565C0),
          ),

          const SizedBox(width: 9),

          SizedBox(
            width: 72,
            child: Text(
              label,
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
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // EMPTY CARD
  // =========================

  Widget _emptyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 45,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 8),

              const Text(
                'No Active Booking Requests',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Pending or accepted requests '
                    'will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ERROR CARD
  // =========================

  Widget _errorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              controller
                  .bookingErrorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed:
              controller.loadPendingBookings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String value) {
    final DateTime? date =
    DateTime.tryParse(value)?.toLocal();

    if (date == null) return value;

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    final String hour =
    date.hour.toString().padLeft(2, '0');

    final String minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '$hour:$minute';
  }
}