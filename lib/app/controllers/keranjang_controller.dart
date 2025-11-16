// file: app/controllers/keranjang_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangController extends GetxController {
  final client = Supabase.instance.client;

  var loading = false.obs;
  var items = <Map<String, dynamic>>[].obs;

  User? get user => client.auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  /// Ambil atau buat keranjang user
  Future<String> _getKeranjangId() async {
    final existing = await client
        .from('keranjang')
        .select('id')
        .eq('user_id', user!.id)
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final inserted = await client
        .from('keranjang')
        .insert({'user_id': user!.id})
        .select()
        .single();

    return inserted['id'];
  }

  /// Ambil isi keranjang lengkap (join obat)
  Future<void> fetch() async {
    if (user == null) return;

    loading.value = true;

    try {
      final keranjang = await client
          .from('keranjang')
          .select('id')
          .eq('user_id', user!.id)
          .maybeSingle();

      if (keranjang == null) {
        items.clear();
        loading.value = false;
        return;
      }

      final data = await client
        .from('keranjang_item')
        .select('id, qty, obat:obat_id (id, nama, harga, gambar_url, stok)')
        .eq('keranjang_id', keranjang['id']);

      items.assignAll(List<Map<String, dynamic>>.from(data));
    } finally {
      loading.value = false;
    }
  }

  /// Tambah item atau tambah qty
  Future<void> tambah(Map<String, dynamic> obat) async {
    loading.value = true;

    try {
      final keranjangId = await _getKeranjangId();

      final existing = await client
          .from('keranjang_item')
          .select()
          .eq('keranjang_id', keranjangId)
          .eq('obat_id', obat['id'])
          .maybeSingle();

      if (existing == null) {
        // item baru
        await client.from('keranjang_item').insert({
          'keranjang_id': keranjangId,
          'obat_id': obat['id'],
          'qty': 1,
        });
      } else {
        // tambah qty
        final qty = (existing['qty'] as num).toInt();

        await client
            .from('keranjang_item')
            .update({'qty': qty + 1})
            .eq('id', existing['id']);
      }

      await fetch();
    } finally {
      loading.value = false;
    }
  }

  /// Kurangi qty
  Future<void> kurang(String itemId, int qty) async {
    if (qty <= 1) {
      await hapus(itemId);
      return;
    }

    await client
        .from('keranjang_item')
        .update({'qty': qty - 1})
        .eq('id', itemId);

    await fetch();
  }

  /// Hapus item dari keranjang
  Future<void> hapus(String itemId) async {
    await client.from('keranjang_item').delete().eq('id', itemId);
    await fetch();
  }

  /// Total harga
  int get totalHarga {
    int total = 0;

    for (var item in items) {
      final obat = item['obat'];
      final harga = (obat['harga'] as num).toInt();
      final qty = (item['qty'] as num).toInt();

      total += harga * qty;
    }

    return total;
  }
}
