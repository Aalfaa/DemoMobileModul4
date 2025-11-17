import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://mxzpomqdyldawngsbdsw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14enBvbXFkeWxkYXduZ3NiZHN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNzc5NjQsImV4cCI6MjA3ODg1Mzk2NH0.RlmhDAGAen7QBFMLwdqcKuRDGQqgpR26DQFXe-z5VNs',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
