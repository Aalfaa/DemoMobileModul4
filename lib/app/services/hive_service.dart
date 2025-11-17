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

  Future<String?> downloadImage(String url, int id) async {
    try {
      final encodedUrl = Uri.encodeFull(url);

      final response = await http.get(Uri.parse(encodedUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/obat_$id.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        print("DOWNLOAD ERROR ${response.statusCode} → $url");
      }
    } catch (e) {
      print("DOWNLOAD EXCEPTION: $e → $url");
    }

    return null;
  }

  Future<void> saveObatList(List<Map<String, dynamic>> list) async {
    for (var o in list) {
      String? localPath;

      if (o['gambar_url'] != null && o['gambar_url'] != "") {
        localPath = await downloadImage(o['gambar_url'], o['id']);
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
