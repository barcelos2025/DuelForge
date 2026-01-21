import 'package:supabase_flutter/supabase_flutter.dart';

/// Provedor centralizado do cliente Supabase.
/// Facilita injeção de dependência e testes.
class SupabaseClientProvider {
  static SupabaseClient get client => Supabase.instance.client;
}
