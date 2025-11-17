import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './app/services/theme_service.dart';
import './app/routes/app_pages.dart';
import './app/controllers/auth_controller.dart';
import './app/providers/supabase_provider.dart';
import './app/controllers/keranjang_controller.dart';
import './app/services/hive_service.dart';
import './app/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INISIALISASI HIVE ---
  final hive = HiveService();
  await hive.init();
  Get.put(hive, permanent: true);

  // Supabase SELALU di-init (tidak tergantung koneksi di sini)
  await SupabaseProvider.init();
  print("Supabase initialized");

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Service global
  Get.put(ConnectivityService(), permanent: true);

  // Controller global
  Get.put(AuthController(), permanent: true);
  Get.put(KeranjangController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeService.mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/splash',
      getPages: AppPages.pages,
    );
  }
}
