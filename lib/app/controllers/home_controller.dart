import 'package:get/get.dart';

class HomeController extends GetxController {
  var obat = <Map<String, dynamic>>[].obs;
  var hasil = <Map<String, dynamic>>[].obs;
  var rekomendasi = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    obat.value = [
      {
        'nama': 'Paracetamol',
        'harga': 5000,
        'stok': 20,
        'kategori': 'Demam',
        'deskripsi': 'Pereda demam dan nyeri.',
      },
      {
        'nama': 'Paracetamol 2',
        'harga': 7000,
        'stok': 15,
        'kategori': 'Demam',
        'deskripsi': 'Pereda demam dan nyeri.',
      },
      {
        'nama': 'OBH Combi',
        'harga': 7000,
        'stok': 12,
        'kategori': 'Batuk',
        'deskripsi': 'Obat batuk berdahak.',
      },
      {
        'nama': 'Vitamin C',
        'harga': 8000,
        'stok': 15,
        'kategori': 'Suplemen',
        'deskripsi': 'Menjaga daya tahan tubuh.',
      },
      {
        'nama': 'Amoxicillin',
        'harga': 12000,
        'stok': 10,
        'kategori': 'Antibiotik',
        'deskripsi': 'Antibiotik untuk infeksi bakteri.',
      },
      {
        'nama': 'Minyak Kayu Putih',
        'harga': 9000,
        'stok': 20,
        'kategori': 'Suplemen',
        'deskripsi': 'Penghangat tubuh.',
      },
      {
        'nama': 'Betadine',
        'harga': 5000,
        'stok': 30,
        'kategori': 'Luka',
        'deskripsi': 'Antiseptik untuk luka.',
      },
    ];

    cari('');
  }

  void cari(String keyword) {
    hasil.clear();
    rekomendasi.clear();

    if (keyword.isEmpty) {
      hasil.assignAll(obat);
      return;
    }

    final cocok = obat
        .where((o) =>
            o['nama'].toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    hasil.assignAll(cocok);

    if (cocok.isNotEmpty) {
      final kategori = cocok.first['kategori'];
      final serupa = obat
          .where((o) =>
              o['kategori'] == kategori &&
              !o['nama'].toLowerCase().contains(keyword.toLowerCase()))
          .toList();

      rekomendasi.assignAll(serupa);
    }
  }
}
