// File: app/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../services/theme_service.dart';
import '../utils/format.dart';
import '../views/detail.dart';
import '../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // 1. GANTI Get.put() menjadi Get.find()
  //    Karena controller sekarang dibuat oleh HomeBinding
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tombol Refresh Data
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => c.fetchObat(), // Panggil fetchObat
          ),
          // Tombol Ganti Tema
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () => themeService.toggle(),
          ),

          // Tombol Logout
          PopupMenuButton(
            icon: const Icon(Icons.person, color: Colors.white),
            offset: const Offset(0, 40),
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    const Text("Logout"),
                  ],
                ),
              )
            ],
            onSelected: (v) {
              if (v == 'logout') Get.find<AuthController>().logout();
            },
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // SEARCH BAR
            TextField(
              controller: _search,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
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
                fillColor: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFECECEC),
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
                // 2. TAMBAHKAN Loading Indicator
                if (c.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                // 3. GANTI nama variabel
                //    'c.hasil' -> 'c.filteredObatList'
                //    'c.rekomendasi' -> 'c.rekomendasiList'
                final utama = c.filteredObatList;
                final rekom = c.rekomendasiList;

                // 4. TAMBAHKAN Pengecekan jika data kosong
                if (utama.isEmpty) {
                  return const Center(
                    child: Text("Obat tidak ditemukan."),
                  );
                }

                return ListView(
                  children: [
                    // GRID PRODUK UTAMA
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: utama.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.70, // FIX OVERFLOW
                      ),
                      itemBuilder: (context, i) {
                        return obatCard(context, utama[i]);
                      },
                    ),

                    // JUDUL REKOMENDASI
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

                    // GRID PRODUK REKOMENDASI
                    if (rekom.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rekom.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.70, // FIX OVERFLOW
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

  // CARD OBAT (FINAL)
  Widget obatCard(BuildContext context, Map<String, dynamic> o) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Get.to(() => DetailPage(obat: o));
      },
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
              )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR SQUARE DEFAULT
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.teal.withOpacity(.18)
                      : Colors.teal.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 40,
                  color: isDark
                      ? Colors.white60
                      : Colors.white70,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              o['nama'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              // Tambahkan 'as int? ?? 0' untuk keamanan
              formatHarga(o['harga'] as int? ?? 0),
              style: TextStyle(
                color: isDark ? Colors.teal.shade200 : Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              // Tambahkan 'as int? ?? 0' untuk keamanan
              "Stok: ${o['stok'] as int? ?? 0}",
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
}