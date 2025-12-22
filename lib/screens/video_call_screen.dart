import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String? token;
  const VideoCallScreen({super.key, required this.channelName, this.token});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final AgoraService _agoraService;

  bool _micEnabled = true;
  bool _videoEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _agoraService = AgoraService();
    _requestPermissions(); // ✅ Request permissions first
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    try {
      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        debugPrint('✅ All permissions granted');
        await _initializeAndJoin();
      } else {
        debugPrint('❌ Permissions denied');

        // Check which permissions were denied
        if (statuses[Permission.camera]!.isDenied) {
          debugPrint('❌ Camera permission denied');
        }
        if (statuses[Permission.microphone]!.isDenied) {
          debugPrint('❌ Microphone permission denied');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera and Microphone permissions are required for video calls',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // Wait a bit before popping
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Permission error: $e')));
      }
    }
  }

  /// Initialize Agora and join channel
  Future<void> _initializeAndJoin() async {
    try {
      await _agoraService.initialize();

      await _agoraService.joinChannel(
        channelName: widget.channelName,
        token: widget.token,
        audioOnly: false,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Toggle microphone
  Future<void> _toggleMicrophone() async {
    try {
      await _agoraService.setLocalAudioEnabled(!_micEnabled);
      setState(() {
        _micEnabled = !_micEnabled;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mic toggle error: $e')));
      }
    }
  }

  /// Toggle camera
  Future<void> _toggleCamera() async {
    try {
      await _agoraService.setLocalVideoEnabled(!_videoEnabled);
      setState(() {
        _videoEnabled = !_videoEnabled;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera toggle error: $e')));
      }
    }
  }

  /// Switch camera
  Future<void> _switchCamera() async {
    try {
      await _agoraService.switchCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Switch camera error: $e')));
      }
    }
  }

  /// Leave call and navigate back
  Future<void> _leaveCall() async {
    try {
      await _agoraService.leaveChannel();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Leave error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call: ${widget.channelName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Requesting permissions...'),
                ],
              ),
            )
          : ValueListenableBuilder<String?>(
              valueListenable: _agoraService.errorMessage,
              builder: (context, errorMsg, child) {
                if (errorMsg != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $errorMsg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _leaveCall,
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    // Main video area
                    ValueListenableBuilder<List<int>>(
                      valueListenable: _agoraService.remoteUsers,
                      builder: (context, remoteUsers, child) {
                        if (remoteUsers.isEmpty) {
                          return Container(
                            color: Colors.black,
                            child: Stack(
                              children: [
                                Center(
                                  child: AgoraVideoView(
                                    controller: VideoViewController(
                                      rtcEngine: _agoraService.engine,
                                      canvas: const VideoCanvas(uid: 0),
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Waiting for remote user...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          color: Colors.black,
                          child: AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: _agoraService.engine,
                              canvas: VideoCanvas(uid: remoteUsers[0]),
                              connection: RtcConnection(
                                channelId: widget.channelName,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Local video PiP
                    ValueListenableBuilder<List<int>>(
                      valueListenable: _agoraService.remoteUsers,
                      builder: (context, remoteUsers, child) {
                        if (remoteUsers.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          top: 50,
                          right: 16,
                          width: 120,
                          height: 160,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: _agoraService.engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Control buttons
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              icon: _micEnabled ? Icons.mic : Icons.mic_off,
                              isActive: _micEnabled,
                              onPressed: _toggleMicrophone,
                            ),
                            _buildControlButton(
                              icon: _videoEnabled
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              isActive: _videoEnabled,
                              onPressed: _toggleCamera,
                            ),
                            _buildControlButton(
                              icon: Icons.flip_camera_android,
                              isActive: true,
                              onPressed: _switchCamera,
                            ),
                            _buildControlButton(
                              icon: Icons.call_end,
                              isActive: false,
                              backgroundColor: Colors.red,
                              onPressed: _leaveCall,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Connection status
                    Positioned(
                      top: 16,
                      left: 16,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _agoraService.connectionState,
                        builder: (context, isConnected, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? Colors.green.withOpacity(0.8)
                                  : Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isConnected
                                      ? Icons.check_circle
                                      : Icons.access_time,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isConnected ? 'Connected' : 'Connecting...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: icon.toString(),
        onPressed: onPressed,
        backgroundColor:
            backgroundColor ??
            (isActive ? Colors.white : Colors.white.withOpacity(0.3)),
        child: Icon(
          icon,
          color: backgroundColor != null
              ? Colors.white
              : (isActive ? Colors.blue : Colors.white),
        ),
      ),
    );
  }
}
