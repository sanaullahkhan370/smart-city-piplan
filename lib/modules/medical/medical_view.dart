import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'medical_controller.dart';

class MedicalView extends GetView<MedicalController> {
  const MedicalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text('Medical Services'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildMedicalCard(
              title: 'Ambulance',
              icon: Icons.local_shipping_outlined,
              color: Colors.red,
              onTap: controller.openAmbulance,
            ),
            _buildMedicalCard(
              title: 'Hospitals',
              icon: Icons.local_hospital_outlined,
              color: Colors.blue,
              onTap: controller.openHospital,
            ),
            _buildMedicalCard(
              title: 'Doctors',
              icon: Icons.medical_services_outlined,
              color: Colors.green,
              onTap: controller.openDoctor,
            ),
            _buildMedicalCard(
              title: 'Pharmacy',
              icon: Icons.local_pharmacy_outlined,
              color: Colors.orange,
              onTap: controller.openPharmacy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 38,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}