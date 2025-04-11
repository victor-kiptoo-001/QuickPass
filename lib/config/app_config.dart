class AppConfig {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const int maxCartItems = 5;
  static const Duration qrCodeValidity = Duration(minutes: 10);
  static const String appName = 'QuickPass';
  static const bool enableAnalytics = true;

  // M-PESA configuration
  static const String mpesaCallbackUrl = 'https://your-domain.com/callback';

  // Encryption key (in production, use secure storage)
  static const String encryptionKey = 'your-32-byte-key-for-encryption';

  // Feature toggles
  static const bool enableLoyaltyPoints = true;
  static const bool enableOfflineMode = true;
}