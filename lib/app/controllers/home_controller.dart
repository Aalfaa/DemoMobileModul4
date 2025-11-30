import 'package:get/get.dart';
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
  final connectivity = Get.find<ConnectivityService>();

  @override
  void onInit() {
    super.onInit();
    fetchObat();
    hive.obatBox.watch().listen((event) {
      final updated = hive.getObatList();
      masterObatList.assignAll(updated);
      filteredObatList.assignAll(updated);
    });
    connectivity.onStatusChange.listen((online) {
      if (online) {
        fetchObat();
      }
    });
  }


  Future<void> fetchObat() async {
    isLoading.value = true;

    final conn = Get.find<ConnectivityService>();
    final online = await conn.isOnline();

    print("Status Online: $online");

    if (!online) {
      final offline = hive.getObatList();
      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
      isLoading.value = false;
      return;
    }

    try {
      final response = await supabase.from('obat').select();

      await hive.saveObatList(response);

      final offline = hive.getObatList();

      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
    } catch (e) {
      print("FETCH ONLINE ERROR: $e");

      final offline = hive.getObatList();
      masterObatList.assignAll(offline);
      filteredObatList.assignAll(offline);
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
        .where((o) =>
            (o['nama'] ?? '')
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
        .toList();

    filteredObatList.assignAll(cocok);

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
