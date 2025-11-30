import 'dart:async';
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

  bool _fetchBusy = false;
  bool _updatingHive = false;
  DateTime? _lastFetch;
  List<Map<String, dynamic>> _cachedKeranjang = [];

  Timer? _hiveDebounce;

  var isOnline = true.obs;

  User? get user => client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();

    fetch();

    hive.keranjangBox.watch().listen((event) {
      if (_updatingHive) return;

      if (_hiveDebounce?.isActive ?? false) _hiveDebounce!.cancel();
      _hiveDebounce = Timer(Duration(milliseconds: 120), () {
        _cachedKeranjang.clear();
        items.assignAll(getKeranjangNormalized());
      });
    });

    connectivity.onStatusChange.listen((online) {
      isOnline.value = online;
      if (online) fetch();
    });
  }

  Future<void> fetch() async {
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
      items.assignAll(getKeranjangNormalized());
      _fetchBusy = false;
      loading.value = false;
      return;
    }

    try {
      if (user == null) {
        items.clear();
        return;
      }

      final keranjang = await client
          .from('keranjang')
          .select('id')
          .eq('user_id', user!.id)
          .maybeSingle();

      if (keranjang == null) {
        items.clear();
        return;
      }

      final result = await client
          .from('keranjang_item')
          .select('id, qty, obat:obat_id (id, nama, harga, gambar_url)')
          .eq('keranjang_id', keranjang['id']);

      _updatingHive = true;
      await hive.saveKeranjangList(result);
      _updatingHive = false;

      _cachedKeranjang.clear();
      items.assignAll(getKeranjangNormalized());
    } catch (e) {
      print("FETCH ERROR: $e");
      items.assignAll(getKeranjangNormalized());
    } finally {
      _fetchBusy = false;
      loading.value = false;
    }
  }

  Future<void> tambahQty(String itemId, int qty) async {
    if (!await connectivity.isOnline()) {
      Get.snackbar("Offline", "Tidak dapat menambah jumlah saat offline");
      return;
    }

    loading.value = true;
    try {
      await client
          .from('keranjang_item')
          .update({'qty': qty + 1})
          .eq('id', itemId);
      await fetch();
    } finally {
      loading.value = false;
    }
  }

  Future<void> tambah(Map<String, dynamic> obat) async {
    if (!await connectivity.isOnline()) {
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
      print("Gagal tambah: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> kurang(String itemId, int qty) async {
    if (!await connectivity.isOnline()) {
      Get.snackbar("Offline", "Tidak dapat mengubah jumlah saat offline");
      return;
    }

    if (qty <= 1) return hapus(itemId);

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

  Future<void> hapus(String itemId) async {
    if (!await connectivity.isOnline()) {
      Get.snackbar("Offline", "Tidak dapat menghapus item saat offline");
      return;
    }

    loading.value = true;

    try {
      await client.from('keranjang_item').delete().eq('id', itemId);

      _updatingHive = true;
      await hive.deleteKeranjangItemById(itemId);
      _updatingHive = false;

      await fetch();
    } catch (e) {
      print("Gagal hapus: $e");
    } finally {
      loading.value = false;
    }
  }

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
    final obat = hive.obatBox.get(item['obat_id']);
    final o = obat != null ? Map<String, dynamic>.from(obat) : {};

    return {
      "id": item['id'],
      "obat_id": item['obat_id'],
      "qty": item['qty'],
      "nama": o['nama'],
      "harga": o['harga'],
      "gambarUrl": o['gambarUrl'] ?? item['gambar_url'],
      "localImagePath": o['localImagePath'],
    };
  }

  Map<String, dynamic> mergeWithObat(Map<String, dynamic> item) {
    final o = hive.obatBox.get(item['obat_id']);

    return {
      ...item,
      "nama": o?['nama'] ?? item['nama'],
      "harga": o?['harga'] ?? item['harga'],
      "gambarUrl": o?['gambarUrl'] ?? item['gambarUrl'],
      "localImagePath": o?['localImagePath'] ?? item['localImagePath'],
    };
  }

  List<Map<String, dynamic>> getKeranjangNormalized() {
    if (_cachedKeranjang.isNotEmpty) return _cachedKeranjang;

    final raw = hive.getKeranjangList();
    _cachedKeranjang =
        raw.map((e) => mergeWithObat(normalizeItem(e))).toList();

    return _cachedKeranjang;
  }
}
