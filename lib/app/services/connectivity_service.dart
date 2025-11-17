import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool lastStatus = false;

  /// Cepat, tidak pakai timeout panjang
  Future<bool> isOnline() async {
    final conn = await _connectivity.checkConnectivity();

    if (conn == ConnectivityResult.none) {
      lastStatus = false;
      return false;
    }

    // PING super cepat, bukan lookup()
    try {
      final socket = await Socket.connect("8.8.8.8", 53,
              timeout: const Duration(milliseconds: 200))
          .whenComplete(() {});

      socket.destroy();
      lastStatus = true;
      return true;
    } catch (_) {
      lastStatus = false;
      return false;
    }
  }
}
