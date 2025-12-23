import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:edustream/config/app_config.dart';
import 'package:flutter/foundation.dart';

class AgoraService {
  // Agora Configuration
  static final String APP_ID = AppConfig.agoraAppId;

  late RtcEngine _agoraEngine;
  int? _localUid;
  bool _isInitialized = false;
  bool _isJoined = false;

  // Callbacks
  final ValueNotifier<bool> connectionState = ValueNotifier(false);
  final ValueNotifier<List<int>> remoteUsers = ValueNotifier([]);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  int? get localUid => _localUid;
  RtcEngine get engine => _agoraEngine;

  /// Initialize Agora engine
  Future<void> initialize() async {
    try {
      _agoraEngine = createAgoraRtcEngine();

      await _agoraEngine.initialize(
        RtcEngineContext(
          appId: APP_ID,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // Set up event handlers BEFORE enabling video/audio
      _setupEventHandlers();

      // Enable video module
      await _agoraEngine.enableVideo();

      // Enable audio module
      await _agoraEngine.enableAudio();

      // Start preview (important for local video)
      await _agoraEngine.startPreview();

      _isInitialized = true;
      debugPrint('✅ Agora engine initialized successfully');
    } catch (e) {
      errorMessage.value = 'Failed to initialize Agora: $e';
      debugPrint('❌ Agora initialization error: $e');
      rethrow;
    }
  }

  /// Set up Agora event handlers
  void _setupEventHandlers() {
    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('✅ Local user joined channel: ${connection.channelId}');
          debugPrint('✅ Local UID: ${connection.localUid}');
          _localUid = connection.localUid;
          _isJoined = true;
          connectionState.value = true;
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('✅ Remote user $remoteUid joined channel');
          final users = List<int>.from(remoteUsers.value);
          if (!users.contains(remoteUid)) {
            users.add(remoteUid);
            remoteUsers.value = users;
            debugPrint('✅ Remote users list: $users');
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint(
            '⚠️ Remote user $remoteUid left channel (reason: $reason)',
          );
          final users = List<int>.from(remoteUsers.value);
          users.remove(remoteUid);
          remoteUsers.value = users;
        },
        onError: (err, msg) {
          errorMessage.value = 'Agora Error ($err): $msg';
          debugPrint('❌ Agora Error ($err): $msg');
        },
        onLeaveChannel: (connection, stats) {
          debugPrint('⚠️ Local user left channel');
          _isJoined = false;
          connectionState.value = false;
          remoteUsers.value = [];
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint(
            '📹 Remote video state changed: UID=$remoteUid, State=$state, Reason=$reason',
          );
        },
        onConnectionStateChanged: (connection, state, reason) {
          debugPrint('🔌 Connection state: $state, Reason: $reason');
        },
      ),
    );
  }

  /// Join a channel
  Future<void> joinChannel({
    required String channelName,
    String? token,
    bool audioOnly = false,
  }) async {
    if (!_isInitialized) {
      throw Exception('Agora engine not initialized');
    }

    try {
      // Generate user ID (0 means Agora will assign one)
      _localUid = 0; // Let Agora assign UID

      debugPrint('🚀 Joining channel: $channelName');
      debugPrint(
        '🔑 Token: ${token?.isEmpty ?? true ? "Empty (Testing Mode)" : "Provided"}',
      );

      // Join channel with proper options
      await _agoraEngine.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: _localUid!,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      // If audioOnly, disable local video
      if (audioOnly) {
        await setLocalVideoEnabled(false);
      }

      debugPrint('✅ Join channel request sent');
    } catch (e) {
      errorMessage.value = 'Failed to join channel: $e';
      debugPrint('❌ Join channel error: $e');
      rethrow;
    }
  }

  /// Leave the channel
  Future<void> leaveChannel() async {
    if (!_isInitialized) return;

    try {
      await _agoraEngine.leaveChannel();
      _isJoined = false;
      connectionState.value = false;
      remoteUsers.value = [];
      debugPrint('✅ Left channel');
    } catch (e) {
      errorMessage.value = 'Failed to leave channel: $e';
      debugPrint('❌ Leave channel error: $e');
      rethrow;
    }
  }

  /// Enable/disable local video
  Future<void> setLocalVideoEnabled(bool enabled) async {
    if (!_isInitialized) return;

    try {
      await _agoraEngine.enableLocalVideo(enabled);
      if (enabled) {
        await _agoraEngine.startPreview();
      } else {
        await _agoraEngine.stopPreview();
      }
      debugPrint('📹 Local video ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Set video error: $e');
      rethrow;
    }
  }

  /// Enable/disable local audio
  Future<void> setLocalAudioEnabled(bool enabled) async {
    if (!_isInitialized) return;

    try {
      await _agoraEngine.enableLocalAudio(enabled);
      debugPrint('🎤 Local audio ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Set audio error: $e');
      rethrow;
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    try {
      await _agoraEngine.switchCamera();
      debugPrint('🔄 Camera switched');
    } catch (e) {
      debugPrint('❌ Switch camera error: $e');
      rethrow;
    }
  }

  /// Dispose and clean up resources
  Future<void> dispose() async {
    try {
      if (_isJoined) {
        await leaveChannel();
      }

      if (_isInitialized) {
        await _agoraEngine.stopPreview();
        await _agoraEngine.release();
        _isInitialized = false;
      }

      // Dispose ValueNotifiers
      connectionState.dispose();
      remoteUsers.dispose();
      errorMessage.dispose();

      debugPrint('✅ Agora service disposed');
    } catch (e) {
      debugPrint('❌ Dispose error: $e');
    }
  }
}
