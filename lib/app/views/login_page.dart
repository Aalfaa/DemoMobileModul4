import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/theme_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController c = Get.find<AuthController>();
  final ThemeService themeService = ThemeService();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFECECEC),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_hospital,
                    size: 50, color: Colors.teal.shade400),

                const SizedBox(height: 10),

                Text(
                  "Masuk Akun",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.teal.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                _buildInput(
                  controller: emailC,
                  label: "Email",
                  icon: Icons.email,
                  isDark: isDark,
                ),

                const SizedBox(height: 14),

                _buildInput(
                  controller: passC,
                  label: "Password",
                  icon: Icons.lock,
                  isDark: isDark,
                  obsec: true,
                ),

                const SizedBox(height: 24),

                Obx(() {
                  return c.loading.value
                      ? const CircularProgressIndicator(color: Colors.teal)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              c.login(
                                emailC.text.trim(),
                                passC.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                }),

                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => Get.offAllNamed('/register'),
                  child: Text(
                    "Belum punya akun? Daftar",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.teal.shade200
                          : Colors.teal.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obsec = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obsec,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
