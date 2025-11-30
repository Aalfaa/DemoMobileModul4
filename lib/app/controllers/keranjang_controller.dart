import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/keranjang_service.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class KeranjangController extends GetxController {
  final client = Supabase.instance.client;
  final keranjangService = Get.find<KeranjangService>();
  final hive = Get.find<HiveService>();
  final connectivity = Get.find<ConnectivityService>();

  var loading = false.obs;
  var items = <Map<String, dynamic>>[].obs;

  // Optimasi performa
  bool _fetchBusy = false;
  DateTime? _lastFetch;
  List<Map<String, dynamic>> _cachedKeranjang = [];

  // Online indicator (untuk UX Step 8)
  var isOnline = true.obs;

  User? get user => client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();

    // Ambil data awal
    fetch();

    // Hive realtime → update UI
    hive.keranjangBox.watch().listen((event) {
      _cachedKeranjang.clear();
      items.assignAll(getKeranjangNormalized());
    });

    // Monitor internet status
    connectivity.onStatusChange.listen((online) {
      isOnline.value = online;
      if (online) {
        fetch(); // sync ulang jika kembali online
      }
    });
  }

  // ============================================================
  // FETCH DATA (offline read, online sync)
  // ============================================================
  Future<void> fetch() async {
    // anti double fetch / debounce
    if (_fetchBusy) return;

    final now = DateTime.now();
    if (_lastFetch != null &&
        now.difference(_lastFetch!) < Duration(milliseconds: 500)) {
      return; 
    }

    _fetchBusy = true;
    _lastFetch = now;
    loading.value = true;

    final online = await connectivity.isOnline();

    if (!online) {
      // OFFLINE MODE → baca hive saja
      items.value = hive.getKeranjangList()
          .map((e) => mergeWithObat(normalizeItem(e)))
          .toList();

      _fetchBusy = false;
      loading.value = false;
      return;
    }

    // ONLINE MODE → ambil dari Supabase lalu simpan ke Hive
    try {
      if (user == null) {
        items.value = [];
        loading.value = false;
        return;
      }

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

      final result = await client
          .from('keranjang_item')
          .select('id, qty, obat:obat_id (id, nama, harga, gambar_url)')
          .eq('keranjang_id', keranjang['id']);

      await hive.saveKeranjangList(result);

      _cachedKeranjang.clear();
      items.assignAll(getKeranjangNormalized());

    } catch (e) {
      print("FETCH ONLINE ERROR: $e");

      items.value = hive.getKeranjangList()
          .map((e) => mergeWithObat(normalizeItem(e)))
          .toList();

    } finally {
      _fetchBusy = false;
      loading.value = false;
    }
  }

  // ============================================================
  // TAMBAH ITEM (online only)
  // ============================================================
  Future<void> tambah(Map<String, dynamic> obat) async {
    final online = await connectivity.isOnline();
    if (!online) {
      Get.snackbar("Offline", "Tidak dapat menambah item saat offline");
      return;
    }
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

  // ============================================================
  // KURANGI ITEM (qty - 1)
  // ============================================================
  Future<void> kurang(String itemId, int qty) async {
    final online = await connectivity.isOnline();
    if (!online) {
      Get.snackbar("Offline", "Tidak dapat mengubah jumlah saat offline");
      return;
    }

    if (qty <= 1) {
      return hapus(itemId);
    }

    loading.value = true;

    try {
      await client
          .from('keranjang_item')
          .update({'qty': qty - 1})
          .eq('id', itemId);

      await fetch();
    } catch (e) {
      print("Gagal update qty: $e");
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // HAPUS ITEM (online only)
  // ============================================================
  Future<void> hapus(String itemId) async {
    final online = await connectivity.isOnline();
    if (!online) {
      Get.snackbar("Offline", "Tidak dapat menghapus item saat offline");
      return;
    }

    loading.value = true;

    try {
      await client.from('keranjang_item').delete().eq('id', itemId);
      await fetch();
    } catch (e) {
      print("Gagal hapus: $e");
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // TOTAL HARGA
  // ============================================================
  int get totalHarga {
    int total = 0;

    for (var item in items) {
      final harga = (item['harga'] ?? 0) as num;
      final qty = (item['qty'] ?? 1) as num;
      total += harga.toInt() * qty.toInt();
    }

    return total;
  }

  // ============================================================
  // NORMALIZE (ambil data obat dari Hive)
  // ============================================================
  Map<String, dynamic> normalizeItem(Map<String, dynamic> item) {
    final obatMap = hive.obatBox.get(item['obat_id']);
    final obat = obatMap != null ? Map<String, dynamic>.from(obatMap) : {};

    return {
      "id": item['id'],
      "obat_id": item['obat_id'],
      "qty": item['qty'],
      "nama": obat['nama'],
      "harga": obat['harga'],
      "gambarUrl": obat['gambarUrl'] ?? item['gambar_url'],
      "localImagePath": obat['localImagePath'],
    };
  }

  // ============================================================
  // MERGE (fallback jika data hive belum lengkap)
  // ============================================================
  Map<String, dynamic> mergeWithObat(Map<String, dynamic> item) {
    final obatOffline = hive.obatBox.get(item['obat_id']);

    return {
      ...item,
      "gambarUrl":
          obatOffline?['gambarUrl'] ?? item['gambarUrl'] ?? item['gambar_url'],
      "localImagePath":
          obatOffline?['localImagePath'] ?? item['localImagePath'],
      "nama": obatOffline?['nama'] ?? item['nama'],
      "harga": obatOffline?['harga'] ?? item['harga'],
    };
  }

  // ============================================================
  // HIVE list caching (optimasi performa)
  // ============================================================
  List<Map<String, dynamic>> getKeranjangNormalized() {
    if (_cachedKeranjang.isNotEmpty) {
      return _cachedKeranjang;
    }

    final raw = hive.getKeranjangList();
    _cachedKeranjang = raw.map((e) => mergeWithObat(normalizeItem(e))).toList();

    return _cachedKeranjang;
  }

  // ============================================================
  // Clean up memory
  // ============================================================
}
