import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/obat_model.dart';

class HiveService {
  late Box obatBox;
  late Box keranjangBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    obatBox = await Hive.openBox('obatBox');
    keranjangBox = await Hive.openBox('keranjangBox');
  }

  Future<void> saveSingleObat(Map data) async {
    // cek apakah gambar berubah
    String? localPath = await downloadImage(
      data['gambar_url'],
      data['id'],
    );

    final map = {
      'id': data['id'],
      'nama': data['nama'],
      'kategori': data['kategori'],
      'harga': data['harga'],
      'stok': data['stok'],
      'deskripsi': data['deskripsi'],
      'gambarUrl': data['gambar_url'],    // simpan yang terbaru
      'localImagePath': localPath,        // update jika berubah
    };

    await obatBox.put(data['id'], map);
  }

  Future<void> deleteObatById(int id) async {
    await obatBox.delete(id);
  }

  Future<void> saveSingleKeranjangItem(Map data) async {
    final obatId = data['obat_id'];

    final obatOffline = obatBox.get(obatId) ?? {};

    final map = {
      'id': data['id'],
      'qty': data['qty'],
      'obat_id': obatId,
    };

    await keranjangBox.put(data['id'].toString(), map);
  }

  Future<void> deleteKeranjangItemById(int id) async {
    await keranjangBox.delete(id.toString());
  }

  Future<String?> downloadImage(String? url, int id) async {
    if (url == null || url.isEmpty) return null;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/obat_$id.jpg';
    final file = File(filePath);

    // 1. Cek apakah file sudah ada
    if (await file.exists()) {
      final obat = obatBox.get(id);

      // 2. Jika URL gambar TIDAK berubah → gunakan file lama
      if (obat != null && obat['gambarUrl'] == url) {
        return filePath; // Tidak download ulang
      }
    }

    try {
      // 3. URL berubah atau file belum ada → download ulang
      final response = await http.get(Uri.parse(url));
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      print("Gagal download gambar $url: $e");
      return null;
    }
  }

  Future<void> saveObatList(List<Map<String, dynamic>> list) async {
    for (var o in list) {
      String? localPath;

      if (o['gambar_url'] != null && o['gambar_url'] != "") {
        localPath = await downloadImage(
            o['gambar_url'],
            o['id'],
          );
      }

      final model = ObatModel(
        id: o['id'],
        nama: o['nama'],
        kategori: o['kategori'],
        harga: o['harga'],
        stok: o['stok'],
        deskripsi: o['deskripsi'],
        gambarUrl: o['gambar_url'],     
        localImagePath: localPath,
      );

      obatBox.put(o['id'], model.toMap());
    }
  }

  List<Map<String, dynamic>> getObatList() {
    return obatBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveKeranjangList(List data) async {
    final box = keranjangBox;
    await box.clear();

    for (var item in data) {
      final obatOnline = item['obat'];

      box.put(item['id'].toString(), {
        'id': item['id'],
        'qty': item['qty'],
        'obat_id': obatOnline['id'],   // SIMPAN OBAT ID SAJA
      });
    }
  }

  List<Map<String, dynamic>> getKeranjangList() {
    return keranjangBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

}
