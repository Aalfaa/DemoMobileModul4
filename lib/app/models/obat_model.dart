class ObatModel {
  final int id;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;
  final String deskripsi;
  final String? localImagePath;

  ObatModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.localImagePath,
  });

  factory ObatModel.fromMap(Map<String, dynamic> map) {
    return ObatModel(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      harga: map['harga'],
      stok: map['stok'],
      deskripsi: map['deskripsi'],
      localImagePath: map['localImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'deskripsi': deskripsi,
      'localImagePath': localImagePath,
    };
  }
}
