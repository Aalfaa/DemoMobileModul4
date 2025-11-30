import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  // MODE ────────────────────────────────────────
  final RxString mode = 'Statis'.obs; // Statis / Dinamis
  final RxString provider = 'Network'.obs; // GPS / Network

  // DATA LOKASI ─────────────────────────────────
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxDouble accuracy = 0.0.obs;
  final RxString timestamp = ''.obs;

  // SPEED (khusus Dinamis)
  final RxDouble speed = 0.0.obs;

  // FIRST FIX TIMER ─────────────────────────────
  final RxString firstFixText = 'Sedang mengambil lokasi terbaru...'.obs;
  bool firstFixDone = false;
  late Stopwatch stopwatch;

  // MAP ─────────────────────────────────────────
  final mapController = MapController();

  StreamSubscription<Position>? _stream;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    initPermission();
    startTracking();
  }

  @override
  void onClose() {
    _stream?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> initPermission() async {
    await Geolocator.requestPermission();
  }

  // FIRST FIX RESET ─────────────────────────────
  void resetFirstFix() {
    firstFixDone = false;
    firstFixText.value = "Sedang mengambil lokasi terbaru...";
    stopwatch = Stopwatch()..start();
  }

  // MODE CHANGE ─────────────────────────────────
  void startTracking() {
    _stream?.cancel();
    _timer?.cancel();

    resetFirstFix();

    if (mode.value == "Dinamis") {
      _startDynamic();
    } else {
      _startStatic();
    }
  }

  // MODE STATIS → update tiap 2 detik
  void _startStatic() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchOnce());
  }

  // MODE DINAMIS → realtime stream
  void _startDynamic() {
    bool isGps = provider.value == "GPS";

    _stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: isGps ? LocationAccuracy.best : LocationAccuracy.low,
        distanceFilter: 1,
      ),
    ).listen((pos) {
      updateLocation(pos);
    });
  }

  // FETCH SEKALI UNTUK MODE STATIS
  Future<void> fetchOnce() async {
    try {
      bool isGps = provider.value == "GPS";

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            isGps ? LocationAccuracy.best : LocationAccuracy.low,
      );

      updateLocation(pos);
    } catch (e) {
      print(e);
    }
  }

  // FORMAT TIMESTAMP ────────────────────────────
  String formatTimestamp(DateTime dt) {
    return "${dt.hour}j ${dt.minute}m ${dt.second}d ${dt.millisecond}s";
  }

  // FORMAT SPEED (m/s → km/jam)
  String formatSpeed(double s) {
    double kmh = s * 3.6;
    return "${kmh.toStringAsFixed(1)} km/jam";
  }

  // UPDATE DATA & MAP ───────────────────────────
  void updateLocation(Position pos) {
    latitude.value = pos.latitude;
    longitude.value = pos.longitude;
    accuracy.value = double.parse(pos.accuracy.toStringAsFixed(1));
    timestamp.value = formatTimestamp(DateTime.now());

    // SPEED (khusus mode dinamis)
    if (mode.value == "Dinamis") {
      speed.value = pos.speed; // m/s
    }

    // FIRST FIX
    if (!firstFixDone) {
      firstFixDone = true;
      stopwatch.stop();
      firstFixText.value =
          "Kecepatan Lokasi Pertama: ${stopwatch.elapsedMilliseconds} ms";
    }

    // Update map
    mapController.move(
      LatLng(pos.latitude, pos.longitude),
      17,
    );
  }
}
