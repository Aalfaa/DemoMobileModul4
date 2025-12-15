import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/supabase_provider.dart';
import '../views/detail.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'restock_channel';

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, sound: true);

    await _registerFCMToken();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    FirebaseMessaging.onMessage.listen(_onForeground);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _handleMessage(initial);
    }
  }

  void _onForeground(RemoteMessage message) {
    print('FCM FOREGROUND PAYLOAD: ${message.data}');

    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Apotek Alfina Rizqy',
      message.notification?.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Restock Notification',
          channelDescription: 'Notifikasi stok obat',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('hehe'),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!);
    _navigateByPayload(data);
  }

  void _handleMessage(RemoteMessage message) {
    print('FCM TAP PAYLOAD: ${message.data}');
    _navigateByPayload(message.data);
  }

  Future<void> _navigateByPayload(Map<String, dynamic> data) async {
    if (data['type'] != 'restock') return;

    final obatId = data['obat_id'];
    if (obatId == null) return;

    final client = SupabaseProvider.client;

    try {
      final obat = await client
          .from('obat')
          .select('*')
          .eq('id', obatId)
          .single();

      Get.to(() => DetailPage(obat: obat));
    } catch (e) {
      print('Gagal membuka detail obat: $e');
    }
  }

  Future<void> _registerFCMToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      print('FCM TOKEN: $token');
    } else {
      print('FCM TOKEN NULL');
    }
  }
}
