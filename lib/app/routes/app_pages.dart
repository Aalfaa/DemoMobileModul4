import 'package:get/get.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/home_page.dart';
import '../views/splash_page.dart';
import '../views/keranjang_page.dart';
import '../bindings/keranjang_binding.dart';

import '../bindings/home_binding.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/register', page: () => RegisterPage()),
    GetPage(name: '/keranjang', page: () => KeranjangPage()),
    
    GetPage(
      name: '/keranjang',
      page: () => KeranjangPage(),
      binding: KeranjangBinding(),
    ),

    GetPage(
      name: '/home',
      page: () => HomePage(),
      binding: HomeBinding(), 
    ),

    GetPage(name: '/splash', page: () => const SplashPage()),
  ];
}