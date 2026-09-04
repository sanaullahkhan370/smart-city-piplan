import 'package:get/get.dart';

import 'super_admin_controller.dart';

class SuperAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminController>(
          () => SuperAdminController(),
    );
  }
}