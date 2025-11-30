import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF6F6F6),

      body: ListView(
        children: [

          const SizedBox(height: 40),

          Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.teal.shade300,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                auth.userEmail ?? "User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),

          menuItem(
            icon: Icons.settings,
            title: "Pengaturan",
            subtitle: "Coming soon",
            onTap: () {},
          ),
          menuItem(
            icon: Icons.notifications,
            title: "Notifikasi",
            subtitle: "Coming soon",
            onTap: () {},
          ),
          menuItem(
            icon: Icons.lock,
            title: "Keamanan",
            subtitle: "Coming soon",
            onTap: () {},
          ),
          menuItem(
            icon: Icons.credit_card,
            title: "Metode Pembayaran",
            subtitle: "Coming soon",
            onTap: () {},
          ),

          const SizedBox(height: 10),

          menuItem(
            icon: Icons.logout,
            title: "Logout",
            subtitle: "",
            isLogout: true,
            onTap: () => auth.logout(),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    bool isLogout = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.red : Colors.teal,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLogout ? Colors.red : null,
            ),
          ),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          onTap: onTap,
          tileColor: Colors.transparent,
        ),

        const Divider(height: 1),
      ],
    );
  }
}
