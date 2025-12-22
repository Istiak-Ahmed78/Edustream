// Example: How to use the Agora Video Call Screen
// 
// In your main.dart or any screen, import and navigate to the video call:
//
// import 'package:edustream/screens/video_call_screen.dart';
//
// // Navigate to video call
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const VideoCallScreen(),
//   ),
// );
//
// Or use named routes if you have them set up:
//
// Navigator.pushNamed(context, '/video-call');
//
// ============================================================
// AGORA SERVICE METHODS
// ============================================================
//
// The AgoraService singleton provides these methods:
//
// 1. initialize() - Initialize the Agora engine
//    await agoraService.initialize();
//
// 2. joinChannel() - Join a video call channel
//    await agoraService.joinChannel();
//
// 3. leaveChannel() - Leave the channel
//    await agoraService.leaveChannel();
//
// 4. setLocalVideoEnabled(bool) - Enable/disable camera
//    await agoraService.setLocalVideoEnabled(true);
//
// 5. setLocalAudioEnabled(bool) - Enable/disable microphone
//    await agoraService.setLocalAudioEnabled(true);
//
// 6. switchCamera() - Switch between front/back camera
//    await agoraService.switchCamera();
//
// 7. dispose() - Clean up resources
//    await agoraService.dispose();
//
// ============================================================
// PROPERTIES & LISTENERS
// ============================================================
//
// - connectionState (ValueNotifier<bool>) - Listen to connection status
//   _agoraService.connectionState.addListener(() { ... });
//
// - remoteUsers (ValueNotifier<List<int>>) - List of remote user UIDs
//   _agoraService.remoteUsers.addListener(() { ... });
//
// - errorMessage (ValueNotifier<String?>) - Error messages
//   _agoraService.errorMessage.addListener(() { ... });
//
// - localUid (int?) - Your local user ID
// - isJoined (bool) - Check if currently in a call
// - isInitialized (bool) - Check if engine is ready
//
// ============================================================
// SECURITY NOTE
// ============================================================
//
// The App ID and Token are currently hardcoded in agora_service.dart
// For PRODUCTION, you should:
//
// 1. Store credentials in environment variables or secure storage
// 2. Generate tokens on your backend server (tokens expire!)
// 3. Use Firebase or your own backend to manage credentials
//
// ============================================================
