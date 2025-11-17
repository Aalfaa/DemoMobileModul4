// file: app/controllers/keranjang_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/keranjang_service.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class KeranjangController extends GetxController {
  final client = Supabase.instance.client;
  final keranjangService = KeranjangService();
  final hive = Get.find<HiveService>();

  var loading = false.obs;
  var items = <Map<String, dynamic>>[].obs;

  User? get user => client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  /// =============================
  /// GET KERANJANG (ONLINE / OFFLINE)
  /// =============================
  Future<void> fetch() async {
    loading.value = true;

    final conn = Get.find<ConnectivityService>();
    final hive = Get.find<HiveService>();

    final online = await conn.isOnline();

    if (!online) {
      // OFFLINE → Ambil dari Hive
      items.value = hive.getKeranjangList()
          .map((e) => mergeWithObat(normalizeItem(e)))
          .toList();
      loading.value = false;
      return;
    }

    try {
      // 1. Ambil keranjang milik user
      final keranjang = await client
          .from('keranjang')
          .select('id')
          .eq('user_id', user!.id)
          .maybeSingle();

      if (keranjang == null) {
        items.value = [];
        loading.value = false;
        return;
      }

      // 2. Ambil item berdasarkan keranjang_id
      final result = await client
          .from('keranjang_item')
          .select('id, qty, obat:obat_id (id, nama, harga, gambar_url)')
          .eq('keranjang_id', keranjang['id']);

      // 3. Simpan di Hive
      hive.saveKeranjangList(result);

      // 4. Pakai data lokal yang sudah konsisten
      items.value = hive.getKeranjangList()
          .map((e) => mergeWithObat(normalizeItem(e)))
          .toList();

    } catch (e) {
      print("FETCH ONLINE ERROR: $e");
      items.value = hive.getKeranjangList().map(normalizeItem).toList();
    } finally {
      loading.value = false;
    }
  }

  /// =============================
  /// TAMBAH ITEM (ONLINE / OFFLINE)
  /// =============================
  Future<void> tambah(Map<String, dynamic> obat) async {
    if (user == null) return;

    loading.value = true;

    try {
      await keranjangService.tambahItem(
        userId: user!.id,
        obatId: obat['id'],
        obatData: obat,
      );

      await fetch();
    } catch (e) {
      print("Gagal tambah item: $e");
    } finally {
      loading.value = false;
    }
  }

  /// =============================
  /// KURANGI QTY
  /// =============================
  Future<void> kurang(String itemId, int qty) async {
    if (qty <= 1) {
      return hapus(itemId);
    }

    loading.value = true;

    try {
      final conn = Get.find<ConnectivityService>();
      final online = await conn.isOnline();

      if (online) {
        await client
            .from('keranjang_item')
            .update({'qty': qty - 1})
            .eq('id', itemId);
      } else {
        await keranjangService.updateQtyOffline(itemId, qty - 1);
      }

      await fetch();
    } catch (e) {
      print("Gagal update qty: $e");
    } finally {
      loading.value = false;
    }
  }

  /// =============================
  /// HAPUS ITEM
  /// =============================
  Future<void> hapus(String itemId) async {
    loading.value = true;

    try {
      final conn = Get.find<ConnectivityService>();
      final online = await conn.isOnline();

      if (online) {
        await client.from('keranjang_item').delete().eq('id', itemId);
      } else {
        await keranjangService.hapusItemOffline(itemId);
      }

      await fetch();
    } catch (e) {
      print("Gagal hapus: $e");
    } finally {
      loading.value = false;
    }
  }

  /// =============================
  /// TOTAL HARGA
  /// =============================
  int get totalHarga {
    int total = 0;

    for (var item in items) {
      final harga = (item['harga'] ?? 0) as num;
      final qty = (item['qty'] ?? 1) as num;
      total += harga.toInt() * qty.toInt();
    }

    return total;
  }

  Map<String, dynamic> normalizeItem(Map<String, dynamic> item) {
    final obatBox = hive.obatBox;
    final obat = Map<String, dynamic>.from(obatBox.get(item['obat_id']) ?? {});

    return {
      "id": item['id'],
      "qty": item['qty'],
      "nama": obat['nama'],
      "harga": obat['harga'],
      "localImagePath": obat['localImagePath'],
      "gambar_url": obat['gambarUrl'],   // dari obat Hive
    };
  }

  Map<String, dynamic> mergeWithObat(Map<String, dynamic> item) {
    final obatOffline = hive.obatBox.get(item['id']);

    return {
      ...item,

      // GAMBAR OFFLINE
      "localImagePath": 
          obatOffline != null
              ? obatOffline['localImagePath']
              : item['localImagePath'],

      // GAMBAR ONLINE
      "gambar_url":
          obatOffline != null
              ? obatOffline['gambarUrl']
              : item['gambar_url'],

      // INFO LAIN
      "nama": obatOffline?['nama'] ?? item['nama'],
      "harga": obatOffline?['harga'] ?? item['harga'],
    };
  }

}
