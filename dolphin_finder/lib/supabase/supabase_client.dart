import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://yglluofsckernbwiypgh.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlnbGx1b2ZzY2tlcm5id2l5cGdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTUwMDgsImV4cCI6MjA1OTU3MTAwOH0.KWfw7mWFtPid89kEmfDg6my7_eSkTioe20pfmciVgpg',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
