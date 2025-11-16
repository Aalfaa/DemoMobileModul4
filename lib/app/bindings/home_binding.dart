// File: app/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan HomeController saat rute /home dipanggil
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}