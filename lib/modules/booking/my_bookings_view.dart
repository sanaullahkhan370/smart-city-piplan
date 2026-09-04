import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_bookings_controller.dart';

class MyBookingsView
    extends GetView<MyBookingsController> {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor:
        const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.loadBookings,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.bookings.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller
            .errorMessage.isNotEmpty) {
          return _errorView();
        }

        if (controller.bookings.isEmpty) {
          return _emptyView();
        }

        return RefreshIndicator(
          onRefresh: controller.loadBookings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
            controller.bookings.length,
            itemBuilder: (context, index) {
              return _bookingCard(
                controller.bookings[index],
              );
            },
          ),
        );
      }),
    );
  }

  // =========================
  // BOOKING CARD
  // =========================

  Widget _bookingCard(
      Map<String, dynamic> booking,
      ) {
    final String bookingId =
        booking['_id']?.toString() ?? '';

    final String status =
        booking['status']?.toString() ??
            'pending';

    final String patientName =
        booking['patientName']
            ?.toString() ??
            '';

    final String phone =
        booking['phone']?.toString() ?? '';

    final String pickupAddress =
        booking['pickupAddress']
            ?.toString() ??
            '';

    final String createdAt =
        booking['createdAt']
            ?.toString() ??
            '';

    final bool isRated =
        booking['isRated'] == true;

    final int savedRating =
        int.tryParse(
          booking['rating']
              ?.toString() ??
              '',
        ) ??
            0;

    final Map<String, dynamic> ambulance =
    booking['ambulance'] is Map
        ? Map<String, dynamic>.from(
      booking['ambulance'] as Map,
    )
        : <String, dynamic>{};

    final String driverName =
        ambulance['driverName']
            ?.toString() ??
            'Driver';

    final String vehicleNumber =
        ambulance['vehicleNumber']
            ?.toString() ??
            '';

    final String ambulanceType =
        ambulance['ambulanceType']
            ?.toString() ??
            '';

    final String ambulancePhone =
        ambulance['phone']?.toString() ??
            '';

    final bool ratingLoading =
        controller.ratingBookingId.value ==
            bookingId;

    return Card(
      margin:
      const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color:
            _statusColor(status).withAlpha(25),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  _statusColor(status),
                  child: Icon(
                    _statusIcon(status),
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleNumber.isEmpty
                            ? 'Ambulance Booking'
                            : vehicleNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      if (ambulanceType.isNotEmpty)
                        Text(
                          ambulanceType,
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
                    _statusColor(status),
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Text(
                    _statusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
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

                _informationRow(
                  icon:
                  Icons.medical_services,
                  label: 'Driver',
                  value: driverName,
                ),

                if (ambulancePhone.isNotEmpty)
                  _informationRow(
                    icon: Icons.call,
                    label: 'Driver Phone',
                    value: ambulancePhone,
                  ),

                if (createdAt.isNotEmpty)
                  _informationRow(
                    icon: Icons.access_time,
                    label: 'Booked',
                    value:
                    _formatDate(createdAt),
                  ),

                if (pickupAddress.isNotEmpty)
                  _informationRow(
                    icon: Icons.location_on,
                    label: 'Pickup',
                    value:
                    'Live location shared',
                  ),

                const SizedBox(height: 10),

                _statusMessage(status),

                if (status == 'accepted') ...[
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller
                            .openAmbulanceLocation(
                          ambulance,
                        );
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFF1565C0,
                        ),
                        foregroundColor:
                        Colors.white,
                        minimumSize:
                        const Size.fromHeight(
                          48,
                        ),
                      ),
                      icon: const Icon(
                        Icons.location_searching,
                      ),
                      label: const Text(
                        'View Ambulance '
                            'Live Location',
                      ),
                    ),
                  ),
                ],

                if (status == 'completed' &&
                    !isRated) ...[
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: ratingLoading
                          ? null
                          : () {
                        controller
                            .rateBooking(
                          bookingId,
                        );
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.amber.shade700,
                        foregroundColor:
                        Colors.white,
                        minimumSize:
                        const Size.fromHeight(
                          48,
                        ),
                      ),
                      icon: ratingLoading
                          ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.star,
                      ),
                      label: const Text(
                        'Rate This Trip',
                      ),
                    ),
                  ),
                ],

                if (status == 'completed' &&
                    isRated) ...[
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                      Colors.amber.shade50,
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Rating',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children:
                          List.generate(
                            5,
                                (index) => Icon(
                              index < savedRating
                                  ? Icons.star
                                  : Icons
                                  .star_border,
                              color: Colors.amber,
                              size: 28,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Thank you for '
                              'your feedback',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATUS MESSAGE
  // =========================

  Widget _statusMessage(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message =
        'Admin کے جواب کا انتظار ہے';
        icon = Icons.hourglass_top;
        break;

      case 'accepted':
        message =
        'Admin نے booking قبول کرلی ہے۔ '
            'آپ Ambulance کی location دیکھ سکتے ہیں۔';
        icon = Icons.check_circle;
        break;

      case 'completed':
        message =
        'آپ کی Ambulance trip مکمل ہوگئی ہے';
        icon = Icons.task_alt;
        break;

      case 'rejected':
        message =
        'Admin نے booking request '
            'قبول نہیں کی';
        icon = Icons.cancel;
        break;

      case 'cancelled':
        message =
        'یہ booking منسوخ کردی گئی ہے';
        icon = Icons.block;
        break;

      default:
        message = status;
        icon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
        _statusColor(status).withAlpha(20),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _statusColor(status),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _statusColor(status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            width: 82,
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

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;

      case 'completed':
        return const Color(0xFF1565C0);

      case 'rejected':
      case 'cancelled':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.local_hospital;

      case 'completed':
        return Icons.task_alt;

      case 'rejected':
      case 'cancelled':
        return Icons.close;

      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';

      case 'accepted':
        return 'ON THE WAY';

      case 'completed':
        return 'COMPLETED';

      case 'rejected':
        return 'REJECTED';

      case 'cancelled':
        return 'CANCELLED';

      default:
        return status.toUpperCase();
    }
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

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed:
              controller.loadBookings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 14),

            Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'آپ کی Ambulance bookings '
                  'یہاں نظر آئیں گی',
              textAlign: TextAlign.center,
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