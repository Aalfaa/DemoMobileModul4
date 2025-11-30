import 'package:demo3/app/bindings/location_binding.dart';
import 'package:demo3/app/views/location_page.dart';
import 'package:demo3/app/views/navigation_page.dart';
import 'package:get/get.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/splash_page.dart';
import '../views/keranjang_page.dart';
import '../bindings/keranjang_binding.dart';

import '../bindings/home_binding.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/register', page: () => RegisterPage()),
    GetPage(
      name: '/location', 
      page: () => LocationPage(),
      binding: LocationBinding()
    ),
    
    GetPage(
      name: '/keranjang',
      page: () => KeranjangPage(),
      binding: KeranjangBinding(),
    ),

    GetPage(
      name: '/home',
      page: () => MainNavigationPage(),
      binding: HomeBinding(), 
    ),

    GetPage(name: '/splash', page: () => const SplashPage()),
  ];
}