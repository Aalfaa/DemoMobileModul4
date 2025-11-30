import 'package:get/get.dart';
import '../controllers/keranjang_controller.dart';
import '../services/keranjang_service.dart';

class KeranjangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeranjangService>(() => KeranjangService(), fenix: true);
    Get.lazyPut<KeranjangController>(() => KeranjangController(), fenix: true);
  }
}

