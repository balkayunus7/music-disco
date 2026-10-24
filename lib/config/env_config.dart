class EnvConfig {
  const EnvConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  factory EnvConfig.fromEnvironment() => const EnvConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String supabaseUrl;
  final String supabaseAnonKey;

  void validate() {
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'https', 'http'}.contains(uri.scheme) ||
        supabaseAnonKey.trim().isEmpty) {
      throw StateError('Provide SUPABASE_URL and SUPABASE_ANON_KEY.');
    }
    if (supabaseAnonKey.startsWith('sb_secret_')) {
      throw StateError('Use a publishable/anon key, never a secret key.');
    }
  }
}
