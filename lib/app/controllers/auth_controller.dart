import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();

  var loading = false.obs;
  var error = ''.obs;

  String? get userEmail => Supabase.instance.client.auth.currentUser?.email;

  void showError(String msg) {
    Get.snackbar(
      "Gagal",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void showSuccess(String msg) {
    Get.snackbar(
      "Berhasil",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> register(
      String email, String password, String username) async {
    loading.value = true;

    try {
      if (username.isEmpty) throw "Username tidak boleh kosong.";
      if (!email.contains("@")) throw "Email tidak valid.";
      if (password.length < 6) throw "Password minimal 6 karakter.";

      final res = await _auth.register(email, password);

      if (res.user == null) throw "Registrasi gagal.";

      await _auth.saveProfile(res.user!.id, username, email);

      showSuccess("Akun berhasil dibuat.");
      Get.offAllNamed('/login');
    } catch (e) {
      showError(e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    loading.value = true;

    try {
      if (!email.contains("@")) throw "Format email tidak valid.";
      if (password.isEmpty) throw "Password tidak boleh kosong.";

      final res = await _auth.login(email, password);

      if (res.user == null) throw "Email atau password salah.";

      showSuccess("Login berhasil.");
      Get.offAllNamed('/home');
    } catch (e) {
      showError(e.toString());
    } finally {
      loading.value = false;
    }
  }

  void logout() async {
    try {
      await _auth.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      showError(e.toString());
    }
  }
}
