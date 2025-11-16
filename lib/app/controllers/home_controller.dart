// File: app/controllers/home_controller.dart
import 'package:get/get.dart';
// IMPORT SupabaseProvider
import '../providers/supabase_provider.dart';

class HomeController extends GetxController {
  // TAMBAHKAN isLoading untuk status loading
  var isLoading = true.obs;

  // UBAH nama variabel agar lebih jelas
  var masterObatList = <Map<String, dynamic>>[].obs;
  var filteredObatList = <Map<String, dynamic>>[].obs;
  var rekomendasiList = <Map<String, dynamic>>[].obs;

  // DAPATKAN Supabase client
  final supabase = SupabaseProvider.client;

  @override
  void onInit() {
    super.onInit();
    // GANTI isi onInit
    // Kita tidak isi data statis, kita panggil fetchObat
    fetchObat();
  }

  // BUAT fungsi baru untuk mengambil data
  Future<void> fetchObat() async {
    try {
      isLoading.value = true;
      rekomendasiList.clear(); // Bersihkan rekomendasi saat refresh

      // Ambil data dari tabel 'obat' kamu
      final response = await supabase
          .from('obat')
          .select('id, nama, kategori, harga, stok, deskripsi');

      // Masukkan data dari Supabase ke master list
      masterObatList.value = List<Map<String, dynamic>>.from(response);

      // Panggil 'cari' dengan string kosong untuk menampilkan semua data
      cari('');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data obat: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // SESUAIKAN fungsi cari
  void cari(String keyword) {
    filteredObatList.clear();
    rekomendasiList.clear();

    if (keyword.isEmpty) {
      filteredObatList.assignAll(masterObatList);
      return;
    }

    final cocok = masterObatList
        .where((o) =>
            o['nama'].toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    filteredObatList.assignAll(cocok);

    if (cocok.isNotEmpty) {
      final kategori = cocok.first['kategori'];
      final serupa = masterObatList
          .where((o) =>
              o['kategori'] == kategori &&
              !o['nama'].toLowerCase().contains(keyword.toLowerCase()))
          .toList();

      rekomendasiList.assignAll(serupa);
    }
  }
}