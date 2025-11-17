import 'package:get/get.dart';
import '../providers/supabase_provider.dart';
import '../services/hive_service.dart';

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

  Future<void> fetchObat() async {
    try {
      isLoading.value = true;

      // ONLINE MODE
      final response = await supabase
          .from('obat')
          .select('id, nama, kategori, harga, stok, deskripsi, gambar_url');

      masterObatList.value = List<Map<String, dynamic>>.from(response);

      // SIMPAN OFFLINE
      await hive.saveObatList(masterObatList);
      print("Data obat online berhasil disimpan ke Hive");

      cari('');
    } catch (e) {
      print("OFFLINE MODE: Data diambil dari Hive");

      masterObatList.value = hive.getObatList();
      cari('');
    } finally {
      isLoading.value = false;
    }
  }

  void cari(String keyword) {
    filteredObatList.clear();
    rekomendasiList.clear();

    if (keyword.isEmpty) {
      filteredObatList.assignAll(masterObatList);
      return;
    }

    final cocok = masterObatList
        .where((o) => o['nama'].toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    filteredObatList.assignAll(cocok);

    if (cocok.isNotEmpty) {
      final kategori = cocok.first['kategori'];
      final serupa = masterObatList
          .where(
            (o) =>
                o['kategori'] == kategori &&
                !o['nama'].toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();

      rekomendasiList.assignAll(serupa);
    }
  }
}
