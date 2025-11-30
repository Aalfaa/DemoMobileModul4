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
      'gambarUrl': data['gambar_url'],   
      'localImagePath': localPath,       
    };

    await obatBox.put(data['id'], map);
  }

  Future<void> deleteObatById(String id) async {
    await obatBox.delete(id);
  }

  Future<void> saveSingleKeranjangItem(Map data) async {
    final obatId = data['obat_id'];

    final map = {
      'id': data['id'],
      'qty': data['qty'],
      'obat_id': obatId,
    };

    map.forEach((key, value) {
      print("$key → value: $value  | type: ${value.runtimeType}");
    });
    await keranjangBox.put(data['id'], map);
  }

  Future<void> deleteKeranjangItemById(String id) async {
    await keranjangBox.delete(id);
  }

  Future<String?> downloadImage(String? url, String id) async {
    if (url == null || url.isEmpty) return null;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/obat_$id.jpg';
    final file = File(filePath);

    if (await file.exists()) {
      final obat = obatBox.get(id);

      if (obat != null && obat['gambarUrl'] == url) {
        return filePath; 
      }
    }

    try {
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

      box.put(item['id'], {
        'id': item['id'],
        'qty': item['qty'],
        'obat_id': obatOnline['id'],
        'nama': obatOnline['nama'],
        'harga': obatOnline['harga'],   // FIX TERPENTING
        'gambar_url': obatOnline['gambar_url'],
      });
    }
  }

  List<Map<String, dynamic>> getKeranjangList() {
    return keranjangBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

}
