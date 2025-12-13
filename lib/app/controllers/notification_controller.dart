import 'package:get/get.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  @override
  void onInit() {
    super.onInit();
    _service.init();
  }
}
