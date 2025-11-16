import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangService {
  final client = Supabase.instance.client;

  /// Ambil atau buat keranjang user
  Future<String> getOrCreateKeranjang(String userId) async {
    // Cek keranjang yang sudah ada
    final existing = await client
        .from('keranjang')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    // Kalau tidak ada → buat baru
    final inserted = await client
        .from('keranjang')
        .insert({'user_id': userId})
        .select()
        .single();

    return inserted['id'];
  }

  /// Tambah obat ke keranjang
  Future<void> tambahItem(String userId, int obatId) async {
    final keranjangId = await getOrCreateKeranjang(userId);

    // Cek apakah obat sudah ada
    final existing = await client
        .from('keranjang_item')
        .select()
        .eq('keranjang_id', keranjangId)
        .eq('obat_id', obatId)
        .maybeSingle();

    if (existing != null) {
      // Sudah ada → qty++
      await client
          .from('keranjang_item')
          .update({'qty': existing['qty'] + 1})
          .eq('id', existing['id']);
    } else {
      // Belum ada → masukkan
      await client.from('keranjang_item').insert({
        'keranjang_id': keranjangId,
        'obat_id': obatId,
        'qty': 1,
      });
    }
  }

  /// Ambil isi keranjang user
  Future<List<Map<String, dynamic>>> getKeranjang(String userId) async {
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
  }

  /// Hapus item dari keranjang
  Future<void> hapusItem(String itemId) async {
    await client.from('keranjang_item').delete().eq('id', itemId);
  }

  /// Update qty (untuk tambah/kurang)
  Future<void> updateQty(String itemId, int qty) async {
    await client.from('keranjang_item').update({'qty': qty}).eq('id', itemId);
  }
}
