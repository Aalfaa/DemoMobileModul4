import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './app/services/theme_service.dart';
import './app/routes/app_pages.dart';
import './app/controllers/auth_controller.dart';
import './app/providers/supabase_provider.dart';
import './app/services/hive_service.dart';
import './app/services/connectivity_service.dart';
import './app/services/keranjang_service.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Geolocator.requestPermission();

  final hive = HiveService();
  await hive.init();
  Get.put(hive, permanent: true);
  
  await SupabaseProvider.init();
  print("Supabase initialized");

  SupabaseProvider.initRealtime(hive);

  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  Get.put(ConnectivityService(), permanent: true);
  Get.put(KeranjangService(), permanent: true);
  Get.put(AuthController(), permanent: true);
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
