import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';

class MainNavigationPage extends StatelessWidget {
  MainNavigationPage({super.key});

  final c = Get.put(MainNavigationController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: c.pages[c.index.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: c.index.value,
          onTap: (i) => c.index.value = i,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: "Promo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Riwayat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Akun",
            ),
          ],
        ),
      );
    });
  }
}
