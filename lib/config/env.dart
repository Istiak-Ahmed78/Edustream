import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  // Agora
  @EnviedField(varName: 'AGORA_APP_ID', obfuscate: true)
  static final String agoraAppId = _Env.agoraAppId;

  @EnviedField(varName: 'AGORA_TOKEN', defaultValue: '')
  static final String agoraToken = _Env.agoraToken;

  // Firebase
  @EnviedField(varName: 'FIREBASE_API_KEY', obfuscate: true)
  static final String firebaseApiKey = _Env.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', obfuscate: true)
  static final String firebaseProjectId = _Env.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', obfuscate: true)
  static final String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;

  // API
  @EnviedField(varName: 'API_URL', obfuscate: true)
  static final String apiUrl = _Env.apiUrl;

  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;

  // App
  @EnviedField(varName: 'ENVIRONMENT')
  static final String environment = _Env.environment;

  @EnviedField(varName: 'APP_NAME')
  static final String appName = _Env.appName;
}
