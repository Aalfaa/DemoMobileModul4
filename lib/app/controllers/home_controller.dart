import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_provider.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;

  var masterObatList = <Map<String, dynamic>>[].obs;
  var filteredObatList = <Map<String, dynamic>>[].obs;
  var rekomendasiList = <Map<String, dynamic>>[].obs;

  final supabase = SupabaseProvider.client;
  final hive = Get.find<HiveService>();

  @override
  void onInit() {
    super.onInit();
    fetchObat();
  }

  /// ====================================
  /// FETCH OBAT ONLINE / OFFLINE
  /// ====================================
  Future<void> fetchObat() async {
    isLoading.value = true;

    final conn = Get.find<ConnectivityService>();
    final online = await conn.isOnline();

    // 🔥 cek internet
    print("Status Online: $online");

    // ================================
    // MODE OFFLINE
    // ================================
    if (!online) {
      final offline = hive.getObatList();
      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
      isLoading.value = false;
      return;
    }

    // ================================
    // MODE ONLINE
    // ================================
    try {
      final response = await supabase.from('obat').select();

      // simpan ke HIVE
      await hive.saveObatList(response);

      final offline = hive.getObatList();

      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
    } catch (e) {
      print("FETCH ONLINE ERROR: $e");

      // fallback kalau Supabase error
      final offline = hive.getObatList();
      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
    } finally {
      isLoading.value = false;
    }
  }

  /// ====================================
  /// FITUR PENCARIAN + REKOMENDASI
  /// ====================================
  void cari(String keyword) {
    filteredObatList.clear();
    rekomendasiList.clear();

    // reset jika kosong
    if (keyword.isEmpty) {
      filteredObatList.assignAll(masterObatList);
      return;
    }

    // Keyword cocok
    final cocok = masterObatList
        .where((o) =>
            (o['nama'] ?? '')
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
        .toList();

    filteredObatList.assignAll(cocok);

    // Jika ada hasil → cari rekomendasi berdasarkan kategori
    if (cocok.isNotEmpty) {
      final kategori = cocok.first['kategori'] ?? '';

      final serupa = masterObatList.where((o) {
        final kat = o['kategori'] ?? '';
        final nama = o['nama']?.toString().toLowerCase() ?? '';

        return kat == kategori && !nama.contains(keyword.toLowerCase());
      }).toList();

      rekomendasiList.assignAll(serupa);
    }
  }
}
