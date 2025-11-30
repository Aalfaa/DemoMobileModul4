import 'package:get/get.dart';
import '../views/home_page.dart';
import '../views/promo_page.dart';
import '../views/riwayat_page.dart';
import '../views/profile_page.dart';

class MainNavigationController extends GetxController {
  var index = 0.obs;

  final pages = [
    HomePage(),
    PromoPage(),
    RiwayatPage(),
    ProfilePage(),
  ];
}
