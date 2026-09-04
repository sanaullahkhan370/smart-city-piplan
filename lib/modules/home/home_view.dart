import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const Color primary = Color(0xFF1256A0);
  static const Color background = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final services = <_CityService>[
      _CityService(
        'Medical Services',
        'Ambulance, hospitals and doctors',
        'Health',
        Icons.local_hospital,
        const Color(0xFFE53935),
        controller.openMedical,
      ),
      _CityService(
        'Rickshaw',
        'Local passenger and loading service',
        'Local Transport',
        Icons.electric_rickshaw,
        const Color(0xFFF57C00),
        controller.openRickshaws,
      ),
      _CityService(
        'Mazda',
        'Medium cargo transport',
        'Local Transport',
        Icons.local_shipping,
        const Color(0xFF1976D2),
        controller.openMazda,
      ),
      _CityService(
        'Pickup',
        'Pickup and delivery service',
        'Local Transport',
        Icons.fire_truck,
        const Color(0xFF00838F),
        controller.openPickups,
      ),
      _CityService(
        'Intercity Transport',
        'Lahore, Mianwali, Karachi and more',
        'Travel',
        Icons.directions_bus,
        const Color(0xFF5E35B1),
        controller.openIntercityTransport,
      ),
      _CityService(
        'Shops & Market',
        'Browse local shops and products',
        'Shopping',
        Icons.storefront,
        const Color(0xFF7CB342),
        controller.openShops,
      ),
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piplan Smart City',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Everything you need in one place',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: controller.openNotifications,
            icon: const Icon(Icons.notifications_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'bookings') controller.openMyBookings();
              if (value == 'logout') controller.logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'bookings', child: Text('My Bookings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.checkRequiredRating,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _welcomeCard(),
            const SizedBox(height: 18),
            TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search medical, shop, transport...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: Obx(
                () => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final category = controller.categories[index];
                    final selected =
                        controller.selectedCategory.value == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => controller.selectCategory(category),
                      selectedColor: primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'City Services',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a service to view available providers',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final query = controller.searchQuery.value;
              final category = controller.selectedCategory.value;
              final filtered = services.where((service) {
                final matchesCategory =
                    category == 'All' || service.category == category;
                final text =
                    '${service.title} ${service.subtitle} ${service.category}'
                        .toLowerCase();
                return matchesCategory && text.contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: Text('No matching service found')),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 600
                          ? 3
                          : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 2 ? 0.94 : 1.05,
                    ),
                    itemBuilder: (_, index) => _serviceCard(filtered[index]),
                  );
                },
              );
            }),
            const SizedBox(height: 22),
            _travelBanner(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeBottomPage,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                label: 'Alerts'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Bookings'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1256A0), Color(0xFF2589D8)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withAlpha(55),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.location_city, color: primary, size: 32),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Assalam-o-Alaikum',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 3),
                Obx(() => Text(
                      controller.userName.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    )),
                const SizedBox(height: 3),
                const Text(
                  'How can we help you today?',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.openEmergency,
            tooltip: 'Emergency',
            icon: const Icon(Icons.sos, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(_CityService service) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: service.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: service.color.withAlpha(35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: service.color.withAlpha(22),
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, color: service.color, size: 34),
              ),
              const SizedBox(height: 11),
              Text(
                service.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                service.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _travelBanner() {
    return Material(
      color: const Color(0xFFEDE7F6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: controller.openIntercityTransport,
        borderRadius: BorderRadius.circular(18),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF5E35B1),
                child: Icon(Icons.route, color: Colors.white),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Travelling outside Piplan?',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Check routes, departure times and contact numbers.'),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityService {
  const _CityService(
    this.title,
    this.subtitle,
    this.category,
    this.icon,
    this.color,
    this.onTap,
  );

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
