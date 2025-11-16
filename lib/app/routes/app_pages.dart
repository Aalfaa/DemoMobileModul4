import 'package:get/get.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/home_page.dart';
import '../views/splash_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/register', page: () => RegisterPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/splash', page: () => const SplashPage()),
  ];
}
