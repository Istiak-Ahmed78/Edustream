import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/webrtc_service.dart';

/// Provider for DatabaseService singleton
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for WebRTCService singleton
final webrtcServiceProvider = Provider<WebRTCService>((ref) {
  return WebRTCService();
});

/// Async provider to initialize WebRTC
final webrtcInitProvider = FutureProvider<void>((ref) async {
  final webrtcService = ref.watch(webrtcServiceProvider);
  await webrtcService.initialize();
});

/// Notifier for managing app-level state
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateUser(String userId, String userName) {
    state = state.copyWith(currentUserId: userId, currentUserName: userName);
  }

  void clearUser() {
    state = state.copyWith(currentUserId: null, currentUserName: null);
  }
}

/// App state model
class AppState {
  final bool isLoading;
  final String? error;
  final String? currentUserId;
  final String? currentUserName;
  final bool isWebRTCInitialized;

  const AppState({
    this.isLoading = false,
    this.error,
    this.currentUserId,
    this.currentUserName,
    this.isWebRTCInitialized = false,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    String? currentUserId,
    String? currentUserName,
    bool? isWebRTCInitialized,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserName: currentUserName ?? this.currentUserName,
      isWebRTCInitialized: isWebRTCInitialized ?? this.isWebRTCInitialized,
    );
  }
}

/// Provider for app state
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(() {
  return AppStateNotifier();
});
