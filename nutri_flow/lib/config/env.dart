/// Compile-time configuration, provided via `--dart-define` (see README for
/// the exact run/build commands). Keeping these as `String.fromEnvironment`
/// means no secrets ever get bundled into source control or into a `.env`
/// asset shipped inside the app package.
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Base URL of the FastAPI PDF service, e.g. https://nutriflow-pdf.onrender.com
  static const pdfServiceUrl = String.fromEnvironment('PDF_SERVICE_URL');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isPdfServiceConfigured => pdfServiceUrl.isNotEmpty;
}
