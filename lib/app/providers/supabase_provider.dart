import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/hive_service.dart';

class SupabaseProvider {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://mxzpomqdyldawngsbdsw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14enBvbXFkeWxkYXduZ3NiZHN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNzc5NjQsImV4cCI6MjA3ODg1Mzk2NH0.RlmhDAGAen7QBFMLwdqcKuRDGQqgpR26DQFXe-z5VNs',
    );
  }

  static void initRealtime(HiveService hive) {
    final client = Supabase.instance.client;

    print("🔥 Supabase Realtime aktif");

    // ============================================================
    // 1. REALTIME UNTUK TABLE OBAT
    // ============================================================
    client.channel('public:obat')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'obat',
        callback: (payload) async {
          final newRow = payload.newRecord;
          final oldRow = payload.oldRecord;

          if (payload.eventType == PostgresChangeEvent.insert ||
              payload.eventType == PostgresChangeEvent.update) {
            await hive.saveSingleObat(newRow);
          }

          if (payload.eventType == PostgresChangeEvent.delete) {
            await hive.deleteObatById(oldRow['id']);
          }
        },
      )
      .subscribe();

    // ============================================================
    // 2. REALTIME UNTUK TABLE KERANJANG_ITEM
    // ============================================================
    client.channel('public:keranjang_item')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'keranjang_item',
        callback: (payload) async {
          final newRow = payload.newRecord;
          final oldRow = payload.oldRecord;

          if (payload.eventType == PostgresChangeEvent.insert ||
              payload.eventType == PostgresChangeEvent.update) {
            await hive.saveSingleKeranjangItem(newRow);
          }

          if (payload.eventType == PostgresChangeEvent.delete) {
            await hive.deleteKeranjangItemById(oldRow['id']);
          }
        },
      )
      .subscribe();
  }

  static SupabaseClient get client => Supabase.instance.client;
}
