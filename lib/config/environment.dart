enum Environment { development, staging, production }

class AppEnvironment {
  static Environment _current = Environment.development;

  static void setEnvironment(Environment env) {
    _current = env;
  }

  static String get apiUrl {
    switch (_current) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging.quickpass.com';
      case Environment.production:
        return 'https://api.quickpass.com';
    }
  }

  static bool get isDebug {
    return _current == Environment.development;
  }
}