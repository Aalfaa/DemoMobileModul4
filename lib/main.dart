import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './app/services/theme_service.dart';
import './app/routes/app_pages.dart';
import './app/controllers/auth_controller.dart';
import './app/providers/supabase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✔ Inisialisasi Supabase lewat provider
  await SupabaseProvider.init();

  // Theme prefs
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Global AuthController
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
