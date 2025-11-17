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
    keranjangBox = await Hive.openBox('keranjangBox'); // ⭐ baru
  }

  Future<String?> downloadImage(String url, int id) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/obat_$id.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {}

    return null;
  }

  Future<void> saveObatList(List<Map<String, dynamic>> list) async {
    for (var o in list) {
      String? localPath;
      if (o['gambar_url'] != null && o['gambar_url'] != '') {
        localPath = await downloadImage(o['gambar_url'], o['id']);
      }

      final model = ObatModel(
        id: o['id'],
        nama: o['nama'],
        kategori: o['kategori'],
        harga: o['harga'],
        stok: o['stok'],
        deskripsi: o['deskripsi'],
        localImagePath: localPath,
      );

      obatBox.put(o['id'], model.toMap());
    }
  }

  List<Map<String, dynamic>> getObatList() {
    return obatBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
