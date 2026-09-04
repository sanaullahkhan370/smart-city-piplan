import 'package:get/get.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/medical/medical_binding.dart';
import '../../modules/medical/medical_view.dart';
import '../../modules/hospital/hospital_binding.dart';
import '../../modules/hospital/hospital_view.dart';
import '../../modules/ambulance/ambulance_binding.dart';
import '../../modules/ambulance/ambulance_view.dart';
import '../../modules/super_admin/super_admin_binding.dart';
import '../../modules/super_admin/super_admin_view.dart';
import '../../modules/admin/admin_binding.dart';
import '../../modules/admin/admin_view.dart';
import '../../modules/doctor_queue_admin/doctor_queue_admin_binding.dart';
import '../../modules/doctor_queue_admin/doctor_queue_admin_view.dart';
import '../../modules/booking/my_bookings_binding.dart';
import '../../modules/booking/my_bookings_view.dart';
import '../../data/services/booking_service.dart';
import '../../modules/rating/required_rating_controller.dart';
import '../../modules/rating/required_rating_view.dart';
import '../../modules/vehicle/vehicle_binding.dart';
import '../../modules/vehicle/vehicle_view.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.medical,
      page: () => const MedicalView(),
      binding: MedicalBinding(),
    ),
    GetPage(
      name: AppRoutes.hospitals,
      page: () => const HospitalView(),
      binding: HospitalBinding(),
    ),
    GetPage(
      name: AppRoutes.ambulance,
      page: () => const AmbulanceView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: AppRoutes.superAdminDashboard,
      page: () => const SuperAdminView(),
      binding: SuperAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorQueueAdmin,
      page: () => const DoctorQueueAdminView(),
      binding: DoctorQueueAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const MyBookingsView(),
      binding: MyBookingsBinding(),
    ),
    GetPage(
      name: AppRoutes.requiredRating,
      page: () => const RequiredRatingView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingService>()) {
          Get.lazyPut<BookingService>(
                () => BookingService(),
          );
        }

        Get.lazyPut<RequiredRatingController>(
              () => RequiredRatingController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.vehicles,
      page: () => const VehicleView(),
      binding: VehicleBinding(),
    ),
  ];
}
