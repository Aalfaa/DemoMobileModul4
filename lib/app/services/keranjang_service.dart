import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class KeranjangService {
  final client = Supabase.instance.client;
  final HiveService hive = Get.find<HiveService>();
  final ConnectivityService connectivity = Get.find<ConnectivityService>();

  Future<bool> _isOnline() async => await connectivity.isOnline();

  Future<void> tambahItem({
    required String userId,
    required int obatId,
    required Map<String, dynamic> obatData,
  }) async {
    final box = hive.keranjangBox;

    if (await _isOnline()) {
      try {
        final keranjangId = await _getOrCreateKeranjang(userId);

        final existing = await client
            .from('keranjang_item')
            .select()
            .eq('keranjang_id', keranjangId)
            .eq('obat_id', obatId)
            .maybeSingle();

        if (existing != null) {
          await client
              .from('keranjang_item')
              .update({'qty': existing['qty'] + 1})
              .eq('id', existing['id']);
        } else {
          await client.from('keranjang_item').insert({
            'keranjang_id': keranjangId,
            'obat_id': obatId,
            'qty': 1,
          });
        }

        await syncFromSupabase(userId);
        return;

      } catch (e) {
        print("Gagal online tambahItem → fallback offline");
      }
    }

    final key = obatId.toString();

    if (box.containsKey(key)) {
      final item = Map<String, dynamic>.from(box.get(key));
      item['qty'] = (item['qty'] ?? 0) + 1;
      box.put(key, item);
    } else {
      box.put(key, {
        'id': obatId,
        'nama': obatData['nama'],
        'harga': obatData['harga'],
        'qty': 1,
        'gambar': obatData['localImagePath'] ?? obatData['gambar_url'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getKeranjang(String userId) async {
    if (await _isOnline()) {
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

        await saveKeranjangHive(data);
        return List<Map<String, dynamic>>.from(data);

      } catch (e) {
        print("Fetch online gagal → fallback offline");
      }
    }

    return hive.getKeranjangList();
  }

  Future<void> saveKeranjangHive(List data) async {
    final box = hive.keranjangBox;
    await box.clear();

    for (var item in data) {
      final obat = item['obat'];
      final qty = item['qty'];

      box.put(obat['id'].toString(), {
        'id': obat['id'],
        'nama': obat['nama'],
        'harga': obat['harga'],
        'qty': qty,
        'gambar': obat['gambar_url'],
      });
    }
  }

  Future<void> saveKeranjangList(List data) async {
    final box = hive.keranjangBox;
    final obatBox = hive.obatBox;

    await box.clear();

    for (var item in data) {
      final obatOnline = item['obat'];

      final obatOffline = obatBox.get(obatOnline['id']);

      final merged = {
        'id': item['id'],
        'qty': item['qty'],
        'nama': obatOnline['nama'],
        'harga': obatOnline['harga'],
        'localImagePath': obatOffline?['localImagePath'],
        'gambar_url': obatOnline['gambar_url'],
      };

      box.put(item['id'].toString(), merged);

      print("KERANJANG SAVE local: ${merged['localImagePath']}, url: ${merged['gambar_url']}");
    }
  }

  Future<void> syncFromSupabase(String userId) async {
    final list = await getKeranjang(userId);
    await saveKeranjangHive(list);
  }

  Future<void> updateQtyOffline(String id, int qty) async {
    final item = hive.keranjangBox.get(id);
    if (item != null) {
      item['qty'] = qty;
      hive.keranjangBox.put(id, item);
    }
  }

  Future<void> hapusItemOffline(String id) async {
    hive.keranjangBox.delete(id);
  }

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
