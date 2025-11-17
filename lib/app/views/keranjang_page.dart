// File: app/views/keranjang_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/keranjang_controller.dart';
import '../utils/format.dart';

class KeranjangPage extends StatelessWidget {
  KeranjangPage({super.key});

  final KeranjangController c = Get.find<KeranjangController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Obx(() {
        if (c.loading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (c.items.isEmpty) {
          return Center(
            child: Text(
              "Keranjang kosong.",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.items.length,
          itemBuilder: (context, i) {
            final item = c.items[i];

            // Online: item['obat'], Offline: item sendiri
            final obat = item;

            final String? imagePath =
              (obat['localImagePath'] != null && obat['localImagePath']!.isNotEmpty)
                  ? obat['localImagePath']
                  : (obat['gambarUrl'] ?? obat['gambar_url']); // fallback ke Hive / Supabase

            print("HIVE IMAGE KERANJANG -> local: ${obat['localImagePath']}, url: ${obat['gambarUrl']}");
            final harga = obat['harga'] ?? item['harga'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // GAMBAR OBAT
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: _buildImage(imagePath),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // NAMA + HARGA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obat['nama']?.toString() ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatHarga((harga as num).toInt()),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TOMBOL QTY
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            c.kurang(item['id'].toString(), item['qty']),
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),

                      Text(
                        "${item['qty']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          // Tambah lewat controller (online/offline dihandle di service)
                          c.tambah(obat);
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),

      // TOTAL + CHECKOUT
      bottomNavigationBar: Obx(() {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 110,
          alignment: Alignment.topCenter,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262626) : Colors.white,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                )
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TOTAL HARGA (di kiri)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total", style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      formatHarga(c.totalHarga),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.teal.withOpacity(.15),
        child: const Icon(Icons.medical_services, size: 28),
      );
    }

    if (path.startsWith("/data") || path.startsWith("/storage")) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return Container(
        color: Colors.teal.withOpacity(.15),
        child: const Icon(Icons.medical_services, size: 28),
      );
    }

    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.teal.withOpacity(.15),
        child: const Icon(Icons.medical_services, size: 28),
      ),
    );
  }
}
