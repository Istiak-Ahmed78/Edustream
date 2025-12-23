import 'package:flutter/material.dart';
import '../services/agora_service.dart';

class AudioCallScreen extends StatefulWidget {
  final String channelName;
  final String? token;
  const AudioCallScreen({super.key, required this.channelName, this.token});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _micEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAndJoin();
  }

  Future<void> _initAndJoin() async {
    try {
      await _agoraService.initialize();
      await _agoraService.joinChannel(
        channelName: widget.channelName,
        token: '',
        audioOnly: true,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleMic() async {
    try {
      await _agoraService.setLocalAudioEnabled(!_micEnabled);
      setState(() => _micEnabled = !_micEnabled);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mic error: $e')));
    }
  }

  Future<void> _leave() async {
    await _agoraService.leaveChannel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_micEnabled ? Icons.mic : Icons.mic_off, size: 64),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleMic,
                    child: Text(_micEnabled ? 'Mute' : 'Unmute'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _leave,
                    child: const Text('End Call'),
                  ),
                ],
              ),
            ),
    );
  }
}
