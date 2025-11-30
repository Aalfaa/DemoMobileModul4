import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  final RxBool lastStatus = false.obs;

  Future<bool> isOnline() async {
    final conn = await _connectivity.checkConnectivity();

    if (conn == ConnectivityResult.none) {
      lastStatus.value = false;
      return false;
    }

    try {
      final socket = await Socket.connect(
        "8.8.8.8",
        53,
        timeout: const Duration(milliseconds: 200),
      ).whenComplete(() {});

      socket.destroy();
      lastStatus.value = true;
      return true;
    } catch (_) {
      lastStatus.value = false;
      return false;
    }
  }

  Stream<bool> get onStatusChange async* {
    await for (final event in _connectivity.onConnectivityChanged) {
      final online = await isOnline();
      yield online;
    }
  }
}
