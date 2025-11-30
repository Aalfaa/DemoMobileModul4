import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/location_controller.dart';

class LocationPage extends StatelessWidget {
  final c = Get.find<LocationController>();

  LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lokasi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => c.startTracking(),
          )
        ],
      ),

      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mode:"),
                  DropdownButton(
                    value: c.mode.value,
                    items: const [
                      DropdownMenuItem(
                          value: "Statis", child: Text("Statis")),
                      DropdownMenuItem(
                          value: "Dinamis", child: Text("Dinamis")),
                    ],
                    onChanged: (v) {
                      c.mode.value = v!;
                      c.startTracking();
                    },
                  ),

                  const SizedBox(height: 12),
                  const Text("Provider Lokasi:"),
                  DropdownButton(
                    value: c.provider.value,
                    items: const [
                      DropdownMenuItem(
                          value: "Network", child: Text("Network")),
                      DropdownMenuItem(value: "GPS", child: Text("GPS")),
                    ],
                    onChanged: (v) {
                      c.provider.value = v!;
                      c.startTracking();
                    },
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Latitude  : ${c.latitude.value}"),
                        Text("Longitude : ${c.longitude.value}"),
                        Text("Accuracy  : ${c.accuracy.value} m"),
                        Text("Timestamp : ${c.timestamp.value}"),

                        const SizedBox(height: 8),
                        Text(
                          c.firstFixText.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),

                        if (c.mode.value == "Dinamis") ...[
                          const SizedBox(height: 8),
                          Text(
                            "Kecepatan: ${c.formatSpeed(c.speed.value)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FlutterMap(
                mapController: c.mapController,
                options: MapOptions(
                  initialCenter:
                      LatLng(c.latitude.value, c.longitude.value),
                  initialZoom: 17,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: "com.apotek.alfina",
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            c.latitude.value, c.longitude.value),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
