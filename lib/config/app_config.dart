import 'env.dart';

class AppConfig {
  // Agora
  static String get agoraAppId => Env.agoraAppId;
  static String get agoraToken => Env.agoraToken;

  // Firebase
  static String get firebaseApiKey => Env.firebaseApiKey;
  static String get firebaseProjectId => Env.firebaseProjectId;

  // API
  static String get apiUrl => Env.apiUrl;
  static String get apiKey => Env.apiKey;

  // Environment checks
  static bool get isProduction => Env.environment == 'production';
  static bool get isDevelopment => Env.environment == 'development';
  static bool get isStaging => Env.environment == 'staging';

  // Debug info (don't use in production)
  static void printConfig() {
    if (isDevelopment) {
      print('=== App Configuration ===');
      print('Environment: ${Env.environment}');
      print('App Name: ${Env.appName}');
      print('API URL: ${Env.apiUrl}');
      print('Agora App ID: ${Env.agoraAppId.substring(0, 8)}...');
      print('========================');
    }
  }
}
