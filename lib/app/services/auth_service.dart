import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final client = Supabase.instance.client;

  Future<AuthResponse> register(String email, String password) async {
    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw "Terjadi kesalahan. Periksa koneksi internet Anda.";
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw e.message; 
    } catch (e) {
      throw "Gagal login. Periksa internet Anda.";
    }
  }

  Future<void> saveProfile(String id, String username, String email) async {
    try {
      await client.from('profiles').insert({
        'id': id,
        'username': username,
        'email': email,
      });
    } catch (e) {
      throw "Gagal menyimpan data profil.";
    }
  }

  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw "Gagal logout. Coba lagi.";
    }
  }
}
