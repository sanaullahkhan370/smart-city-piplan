import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'required_rating_controller.dart';

class RequiredRatingView
    extends GetView<RequiredRatingController> {
  const RequiredRatingView({super.key});

@override
Widget build(BuildContext context) {
  return PopScope(
    // Rating سے پہلے Back بند
    canPop: false,
    child: Scaffold(
      backgroundColor:
      const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (controller
              .errorMessage.isNotEmpty) {
            return _errorView();
          }

          final Map<String, dynamic>?
          booking =
              controller
                  .requiredBooking.value;

          if (booking == null) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          return _ratingContent(booking);
        }),
      ),
    ),
  );
}

Widget _ratingContent(
    Map<String, dynamic> booking,
    ) {
  final Map<String, dynamic> ambulance =
  booking['ambulance'] is Map
      ? Map<String, dynamic>.from(
    booking['ambulance'] as Map,
  )
      : <String, dynamic>{};

  final String vehicleNumber =
      ambulance['vehicleNumber']
          ?.toString() ??
          'Ambulance';

  final String driverName =
      ambulance['driverName']
          ?.toString() ??
          'Driver';

  final String ambulanceType =
      ambulance['ambulanceType']
          ?.toString() ??
          '';

  return Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color:
                    Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: Colors.green,
                    size: 52,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Trip Completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Dashboard پر جانے سے پہلے '
                      'اپنی Ambulance trip کو '
                      'rating دیں',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFF4F7FB),
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _informationRow(
                        icon:
                        Icons.local_hospital,
                        label: 'Ambulance',
                        value: vehicleNumber,
                      ),

                      _informationRow(
                        icon: Icons.person,
                        label: 'Driver',
                        value: driverName,
                      ),

                      if (ambulanceType.isNotEmpty)
                        _informationRow(
                          icon: Icons
                              .medical_services,
                          label: 'Type',
                          value: ambulanceType,
                          showDivider: false,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'کم از کم ایک star منتخب کرنا لازمی ہے',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                      () => Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) {
                        final int star =
                            index + 1;

                        final bool selected =
                            star <=
                                controller
                                    .selectedRating
                                    .value;

                        return IconButton(
                          onPressed: controller
                              .isSubmitting.value
                              ? null
                              : () {
                            controller
                                .selectRating(
                              star,
                            );
                          },
                          icon: Icon(
                            selected
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Obx(
                      () => Text(
                    controller.selectedRating
                        .value ==
                        0
                        ? 'Select your rating'
                        : '${controller.selectedRating.value} out of 5',
                    style: TextStyle(
                      color: controller
                          .selectedRating
                          .value ==
                          0
                          ? Colors.grey
                          : Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(
                        () => ElevatedButton.icon(
                      onPressed: controller
                          .isSubmitting.value ||
                          controller
                              .selectedRating
                              .value ==
                              0
                          ? null
                          : controller
                          .submitRating,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                          0xFF1565C0,
                        ),
                        foregroundColor:
                        Colors.white,
                      ),
                      icon: controller
                          .isSubmitting.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.star),
                      label: Text(
                        controller
                            .isSubmitting.value
                            ? 'Submitting...'
                            : 'Submit Rating',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 15,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Rating submit کرنے کے بعد '
                            'Dashboard کھلے گا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _informationRow({
  required IconData icon,
  required String label,
  required String value,
  bool showDivider = true,
}) {
  return Column(
    children: [
      Row(
        children: [
          Icon(
            icon,
            color:
            const Color(0xFF1565C0),
            size: 21,
          ),

          const SizedBox(width: 10),

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
              value,
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      if (showDivider)
        const Divider(height: 22),
    ],
  );
}

Widget _errorView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.red,
            size: 60,
          ),

          const SizedBox(height: 14),

          const Text(
            'Rating Check Failed',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed:
            controller.loadRequiredRating,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
}