import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../services/theme_service.dart';
import '../utils/format.dart';
import '../views/detail.dart';
import '../services/connectivity_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController c = Get.find<HomeController>();
  final ThemeService themeService = ThemeService();
  final TextEditingController _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        title: const Text(
          "Apotek Alfina Rizqy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () => themeService.toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Get.toNamed('/keranjang'),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () => Get.toNamed('/location'),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Obx(() {
              final conn = Get.find<ConnectivityService>();

              if (conn.lastStatus.value) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.red.shade400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Offline mode - menggunakan cache",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            TextField(
              controller: _search,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Cari obat...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECECEC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => c.cari(v),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                final utama = c.filteredObatList;
                final rekom = c.rekomendasiList;

                if (utama.isEmpty) {
                  return const Center(child: Text("Obat tidak ditemukan."));
                }

                return ListView(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: utama.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.69,
                      ),
                      itemBuilder: (context, i) {
                        return obatCard(context, utama[i]);
                      },
                    ),

                    if (rekom.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Text(
                        "Rekomendasi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal.shade300,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (rekom.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rekom.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, i) {
                          return obatCard(context, rekom[i]);
                        },
                      ),

                    const SizedBox(height: 30),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget obatCard(BuildContext context, Map<String, dynamic> o) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String? imagePath =
        (o['localImagePath'] != null && o['localImagePath']!.isNotEmpty)
            ? o['localImagePath']
            : (o['gambarUrl'] ?? o['gambar_url']);

    return GestureDetector(
      onTap: () => Get.to(() => DetailPage(obat: o)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(imagePath, isDark),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              o['nama'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              formatHarga(o['harga'] ?? 0),
              style: TextStyle(
                color: isDark ? Colors.teal.shade200 : Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              "Stok: ${o['stok'] ?? 0}",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path, bool isDark) {
    if (path == null || path.isEmpty) {
      return _defaultImage(isDark);
    }

    if (path.startsWith("/data") || path.startsWith("/storage")) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return _defaultImage(isDark);
    }

    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _defaultImage(isDark),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2),
        );
      },
    );
  }

  Widget _defaultImage(bool isDark) {
    return Container(
      color:
          isDark ? Colors.teal.withOpacity(.18) : Colors.teal.withOpacity(.15),
      child: Icon(
        Icons.medical_services_rounded,
        size: 40,
        color: isDark ? Colors.white60 : Colors.white70,
      ),
    );
  }
}
