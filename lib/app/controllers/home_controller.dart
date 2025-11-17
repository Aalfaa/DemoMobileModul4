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

  bool sudahLoad = false;

  Future<void> fetchObat() async {
    if (sudahLoad) return;
    sudahLoad = true;

    final conn = Get.find<ConnectivityService>();
    final hive = Get.find<HiveService>();

    isLoading.value = true;

    final online = await conn.isOnline();

    print("Status Online: $online");

    if (!online) {
      masterObatList.value = hive.getObatList();
      filteredObatList.value = masterObatList;
      isLoading.value = false;
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('obat')
          .select();

      hive.saveObatList(response);

      masterObatList.value = hive.getObatList();
      filteredObatList.value = masterObatList;
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
        .where((o) => o['nama']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();

    filteredObatList.assignAll(cocok);

    if (cocok.isNotEmpty) {
      final kategori = cocok.first['kategori'];
      final serupa = masterObatList
          .where(
            (o) =>
                o['kategori'] == kategori &&
                !o['nama']
                    .toString()
                    .toLowerCase()
                    .contains(keyword.toLowerCase()),
          )
          .toList();

      rekomendasiList.assignAll(serupa);
    }
  }
}
