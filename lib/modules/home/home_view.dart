import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.sizeOf(context).width;

    final int gridColumns =
    screenWidth >= 900 ? 4 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          AppStrings.home,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              controller.showComingSoon(
                'Notifications',
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),

          // بڑی screen پر My Bookings
          // icon کے ساتھ نام بھی دکھے گا
          if (screenWidth >= 600)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
              ),
              child: TextButton.icon(
                onPressed:
                controller.openMyBookings,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                  Colors.white.withAlpha(30),
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.receipt_long,
                ),
                label: const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed:
              controller.openMyBookings,
              tooltip: 'My Bookings',
              icon: const Icon(
                Icons.receipt_long,
              ),
            ),

          IconButton(
            tooltip: 'Logout',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
          controller.checkRequiredRating,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),

                const SizedBox(height: 24),

                // =========================
                // VEHICLE BOOKING SECTION
                // =========================

                _buildSectionTitle(
                  icon: Icons.directions_car,
                  title: 'Book a Vehicle',
                  color: Colors.blue,
                ),

                const SizedBox(height: 6),

                Text(
                  'Select the service you need',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: gridColumns,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                  screenWidth >= 900
                      ? 1.35
                      : 1.20,
                  children: [
                    // Ambulance
                    _buildVehicleCard(
                      title: 'Ambulance',
                      subtitle:
                      'Emergency medical transport',
                      icon:
                      Icons.emergency_outlined,
                      color: Colors.red,
                      onTap:
                      controller.openAmbulances,
                    ),

                    // Rickshaw
                    _buildVehicleCard(
                      title: 'Rickshaw',
                      subtitle:
                      'Local loading and delivery',
                      icon:
                      Icons.electric_rickshaw,
                      color: Colors.orange.shade800,
                      onTap:
                      controller.openRickshaws,
                    ),

                    // Mazda
                    _buildVehicleCard(
                      title: 'Mazda',
                      subtitle:
                      'Medium cargo transport',
                      icon:
                      Icons.local_shipping_outlined,
                      color: Colors.blue.shade700,
                      onTap: controller.openMazda,
                    ),

                    // Pickup
                    _buildVehicleCard(
                      title: 'Pickup',
                      subtitle:
                      'Pickup and delivery service',
                      icon:
                      Icons.fire_truck_outlined,
                      color: Colors.teal,
                      onTap:
                      controller.openPickups,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =========================
                // SMART CITY SERVICES
                // =========================

                _buildSectionTitle(
                  icon: Icons.location_city,
                  title: 'Smart City Services',
                  color: Colors.indigo,
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: gridColumns,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                  screenWidth >= 900
                      ? 1.35
                      : 1.25,
                  children: [
                    _buildFeatureCard(
                      title: 'Medical',
                      icon: Icons
                          .local_hospital_outlined,
                      color: Colors.red,
                      onTap:
                      controller.openMedical,
                    ),

                    _buildFeatureCard(
                      title: 'Complaints',
                      icon: Icons
                          .report_problem_outlined,
                      color: Colors.deepOrange,
                      onTap:
                      controller.openComplaints,
                    ),

                    _buildFeatureCard(
                      title: 'Bills',
                      icon:
                      Icons.receipt_long_outlined,
                      color: Colors.orange,
                      onTap: controller.openBills,
                    ),

                    _buildFeatureCard(
                      title: 'City Services',
                      icon: Icons
                          .miscellaneous_services_outlined,
                      color: Colors.blue,
                      onTap:
                      controller.openServices,
                    ),

                    _buildFeatureCard(
                      title: 'Announcements',
                      icon:
                      Icons.campaign_outlined,
                      color: Colors.purple,
                      onTap: controller
                          .openAnnouncements,
                    ),

                    _buildFeatureCard(
                      title: 'Emergency',
                      icon:
                      Icons.emergency_outlined,
                      color: Colors.green,
                      onTap:
                      controller.openEmergency,
                    ),

                    _buildFeatureCard(
                      title: 'Property',
                      icon:
                      Icons.home_work_outlined,
                      color: Colors.teal,
                      onTap:
                      controller.openProperty,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =========================
                // ANNOUNCEMENT
                // =========================

                _buildSectionTitle(
                  icon: Icons.campaign_outlined,
                  title: 'Latest Announcement',
                  color: Colors.purple,
                ),

                const SizedBox(height: 12),

                _buildAnnouncementCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex:
          controller.selectedIndex.value,
          onTap:
          controller.changeBottomPage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon:
              Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_outlined,
              ),
              activeIcon:
              Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon:
              Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ==================================
  // SECTION TITLE
  // ==================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ==================================
  // WELCOME CARD
  // ==================================

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(64),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration:
            const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_city,
              size: 40,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Obx(
                      () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================
  // GENERIC VEHICLE CARD
  // ==================================

  Widget _buildVehicleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: color.withAlpha(45),
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                padding:
                const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: color,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================
  // NORMAL FEATURE CARD
  // ==================================

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================
  // ANNOUNCEMENT CARD
  // ==================================

  Widget _buildAnnouncementCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
              Color(0xFFE3F2FD),
              child: Icon(
                Icons.campaign,
                color: Colors.blue,
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Piplan Smart City',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'City services and important '
                        'announcements will be '
                        'available here.',
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}