import 'package:flutter/material.dart';
import '../controllers/keranjang_controller.dart';
import '../utils/format.dart';
import 'package:get/get.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> obat;

  const DetailPage({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;
    final priceColor = isDark ? Colors.teal.shade200 : Colors.teal.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Text(
          obat['nama'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (obat['gambar_url'] == null || obat['gambar_url'].isEmpty)
                    ? Container(
                        color: isDark
                            ? Colors.teal.withOpacity(.20)
                            : Colors.teal.withOpacity(.15),
                        child: Icon(
                          Icons.medical_services_rounded,
                          size: 90,
                          color: isDark ? Colors.white60 : Colors.white,
                        ),
                      )
                    : Image.network(
                        obat['gambar_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: isDark
                                ? Colors.teal.withOpacity(.20)
                                : Colors.teal.withOpacity(.15),
                            child: Icon(
                              Icons.medical_services_rounded,
                              size: 90,
                              color: isDark ? Colors.white60 : Colors.white,
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 22),

            // NAMA PRODUK
            Text(
              obat['nama'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            // KATEGORI
            Text(
              "Kategori: ${obat['kategori']}",
              style: TextStyle(
                fontSize: 15,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // HARGA
            Text(
              formatHarga(obat['harga']),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: priceColor,
              ),
            ),

            const SizedBox(height: 6),

            // STOK
            Text(
              "Stok tersedia: ${obat['stok']}",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 22),

            // DESKRIPSI CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    obat['deskripsi'],
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final keranjang = Get.find<KeranjangController>();
            keranjang.tambah(obat);
            Get.snackbar(
              "Berhasil",
              "Obat ditambahkan ke keranjang",
              backgroundColor: Colors.teal,
              colorText: Colors.white,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Tambah ke Keranjang",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
