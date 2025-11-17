import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/hive_service.dart';

class KeranjangService {
  final client = Supabase.instance.client;
  final HiveService hive = Get.find<HiveService>();

  /// Cek apakah user sedang online
  bool get isOnline => client.auth.currentSession != null;

  /// --- TAMBAH ITEM ---
  Future<void> tambahItem({
    required String userId,
    required int obatId,
    required Map<String, dynamic> obatData,
  }) async {
    // Jika ONLINE, simpan ke Supabase
    if (isOnline) {
      try {
        final keranjangId = await _getOrCreateKeranjang(userId);

        // cek apakah item sudah ada
        final existing = await client
            .from('keranjang_item')
            .select()
            .eq('keranjang_id', keranjangId)
            .eq('obat_id', obatId)
            .maybeSingle();

        if (existing != null) {
          // update qty
          await client
              .from('keranjang_item')
              .update({'qty': existing['qty'] + 1})
              .eq('id', existing['id']);
        } else {
          // insert baru
          await client.from('keranjang_item').insert({
            'keranjang_id': keranjangId,
            'obat_id': obatId,
            'qty': 1,
          });
        }

        return;
      } catch (e) {
        // kalau gagal → fallback offline
        print("ONLINE gagal, pakai offline: $e");
      }
    }

    // --- OFFLINE MODE ---
    final box = hive.keranjangBox;

    if (box.containsKey(obatId.toString())) {
      final item = box.get(obatId.toString());
      item['qty'] += 1;
      box.put(obatId.toString(), item);
    } else {
      box.put(obatId.toString(), {
        'id': obatId,
        'nama': obatData['nama'],
        'harga': obatData['harga'],
        'qty': 1,
        'gambar': obatData['localImagePath'] ?? obatData['gambar_url'],
      });
    }
  }

  /// --- AMBIL ISI KERANJANG ---
  Future<List<Map<String, dynamic>>> getKeranjang(String userId) async {
    if (isOnline) {
      try {
        final keranjang = await client
            .from('keranjang')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (keranjang == null) return [];

        final data = await client
            .from('keranjang_item')
            .select('id, qty, obat:obat_id (id, nama, harga, gambar_url)')
            .eq('keranjang_id', keranjang['id']);

        return List<Map<String, dynamic>>.from(data);
      } catch (_) {
        print("ONLINE gagal saat get keranjang → fallback offline");
      }
    }

    // --- OFFLINE MODE ---
    final box = hive.keranjangBox;
    return box.values
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// --- UPDATE QTY OFFLINE ---
  Future<void> updateQtyOffline(String itemKey, int qty) async {
    final box = hive.keranjangBox;
    final item = box.get(itemKey);
    item['qty'] = qty;
    box.put(itemKey, item);
  }

  /// --- HAPUS ITEM OFFLINE ---
  Future<void> hapusItemOffline(String itemKey) async {
    await hive.keranjangBox.delete(itemKey);
  }

  /// --- ONLINE ONLY ---
  /// Membuat keranjang di Supabase jika belum ada
  Future<String> _getOrCreateKeranjang(String userId) async {
    final existing = await client
        .from('keranjang')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return existing['id'].toString();

    final inserted = await client
        .from('keranjang')
        .insert({'user_id': userId})
        .select()
        .single();

    return inserted['id'].toString();
  }
}
