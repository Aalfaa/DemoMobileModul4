import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController c = Get.find<AuthController>();

  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final pass2C = TextEditingController();

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
              children: [
                Icon(Icons.person_add,
                    size: 50, color: Colors.teal.shade400),

                const SizedBox(height: 10),

                Text(
                  "Daftar Akun",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.teal.shade700,
                  ),
                ),

                const SizedBox(height: 22),

                _input(usernameC, "Username", Icons.person, isDark),
                const SizedBox(height: 14),

                _input(emailC, "Email", Icons.email, isDark),
                const SizedBox(height: 14),

                _input(passC, "Password", Icons.lock, isDark, obsec: true),
                const SizedBox(height: 14),

                _input(pass2C, "Konfirmasi Password", Icons.lock_outline,
                    isDark,
                    obsec: true),

                const SizedBox(height: 24),

                Obx(() {
                  return c.loading.value
                      ? const CircularProgressIndicator(color: Colors.teal)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passC.text != pass2C.text) {
                                c.showError("Password tidak sama.");
                                return;
                              }

                              c.register(
                                emailC.text.trim(),
                                passC.text.trim(),
                                usernameC.text.trim(),
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
                              "Daftar",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                }),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Get.offAllNamed('/login'),
                  child: Text(
                    "Sudah punya akun? Login",
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

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon,
    bool isDark, {
    bool obsec = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obsec,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
