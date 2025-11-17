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
    final online = await _isOnline();

    if (online) {
      try {
        final keranjangId = await _getOrCreateKeranjang(userId);

        final existing = await client
            .from('keranjang_item')
            .select('id, qty')
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
        print("ERROR online tambahItem → gunakan offline");
      }
    }

    final key = obatId.toString();

    if (box.containsKey(key)) {
      final item = Map<String, dynamic>.from(box.get(key));
      item['qty'] = (item['qty'] ?? 0) + 1;
      box.put(key, item);
    } else {
      box.put(key, {
        'id': key, 
        'obat_id': obatId,
        'qty': 1,
        'nama': obatData['nama'],
        'harga': obatData['harga'],
        'localImagePath': obatData['localImagePath'],
        'gambar_url': obatData['gambar_url'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getKeranjang(String userId) async {
    final online = await _isOnline();

    if (online) {
      try {
        final keranjang = await client
            .from('keranjang')
            .select('id')
            .eq('user_id', userId)
            .single();

        final list = await client
            .from('keranjang_item')
            .select('''
              id,
              qty,
              obat:obat_id (
                id,
                nama,
                harga,
                gambar_url
              )
            ''')
            .eq('keranjang_id', keranjang['id']);

        await saveKeranjangHive(list);

        return mapOnlineToUnified(list);

      } catch (e) {
        print("ERROR getKeranjang ONLINE → fallback offline");
      }
    }

    final offline = hive.getKeranjangList();
    return mapOfflineToUnified(offline);
  }

  Future<void> saveKeranjangHive(List data) async {
    final box = hive.keranjangBox;
    await box.clear();

    for (var item in data) {
      final obat = item['obat'] ?? {};

      box.put(item['id'].toString(), {
        'id': item['id'],
        'obat_id': obat['id'],
        'qty': item['qty'],
        'nama': obat['nama'],
        'harga': obat['harga'],
        'localImagePath': hive.obatBox.get(obat['id'])?['localImagePath'],
        'gambar_url': obat['gambar_url'],
      });
    }
  }

  List<Map<String, dynamic>> mapOfflineToUnified(List data) {
    return data.map((item) {
      final obatOffline = hive.obatBox.get(item['obat_id']) ?? {};

      return {
        'id': item['id'],
        'obat_id': item['obat_id'],
        'qty': item['qty'],
        'nama': item['nama'] ?? obatOffline['nama'],
        'harga': item['harga'] ?? obatOffline['harga'],
        'localImagePath': item['localImagePath'] ?? obatOffline['localImagePath'],
        'gambar_url': item['gambar_url'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> mapOnlineToUnified(List data) {
    return data.map((item) {
      final o = item['obat'] ?? {};
      final offline = hive.obatBox.get(o['id']) ?? {};

      return {
        'id': item['id'],
        'obat_id': o['id'],
        'qty': item['qty'],
        'nama': o['nama'],
        'harga': o['harga'],
        'localImagePath': offline['localImagePath'],
        'gambar_url': o['gambar_url'],
      };
    }).toList();
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
        .select('id')
        .eq('user_id', userId)
        .single();

    return existing['id'];
  }
}
