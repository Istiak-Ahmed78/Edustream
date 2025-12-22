import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  final Logger _logger = Logger();

  factory WebRTCService() {
    return _instance;
  }

  WebRTCService._internal();

  RTCPeerConnection get peerConnection => _peerConnection;
  MediaStream get localStream => _localStream;

  /// Initialize the WebRTC service and request permissions
  Future<void> initialize() async {
    try {
      _logger.i('Initializing WebRTC service...');

      // Request camera and microphone permissions
      await _requestPermissions();

      // Create peer connection configuration
      final iceServers = [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ];

      final configuration = {'iceServers': iceServers};

      _peerConnection = await createPeerConnection(configuration);
      _setupPeerConnectionListeners();

      _logger.i('WebRTC service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    try {
      final cameras = await Helper.cameras;
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
    } catch (e) {
      _logger.e('Camera permission error: $e');
      rethrow;
    }
  }

  /// Start local media stream (camera and microphone)
  Future<MediaStream> startLocalStream({
    bool audio = true,
    bool video = true,
  }) async {
    try {
      final constraints = {
        'audio': audio,
        'video': video
            ? {
                'mandatory': {
                  'minWidth': 640,
                  'minHeight': 480,
                  'minFrameRate': 30,
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _logger.i('Local stream started');

      // Add tracks to peer connection
      for (final track in _localStream.getTracks()) {
        await _peerConnection.addTrack(track, _localStream);
      }

      return _localStream;
    } catch (e) {
      _logger.e('Failed to start local stream: $e');
      rethrow;
    }
  }

  /// Stop the local media stream
  Future<void> stopLocalStream() async {
    try {
      for (final track in _localStream.getTracks()) {
        await track.stop();
      }
      _logger.i('Local stream stopped');
    } catch (e) {
      _logger.e('Failed to stop local stream: $e');
    }
  }

  /// Create an offer for establishing a connection
  Future<RTCSessionDescription> createOffer() async {
    try {
      final offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);
      _logger.i('Offer created');
      return offer;
    } catch (e) {
      _logger.e('Failed to create offer: $e');
      rethrow;
    }
  }

  /// Create an answer to an offer
  Future<RTCSessionDescription> createAnswer() async {
    try {
      final answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);
      _logger.i('Answer created');
      return answer;
    } catch (e) {
      _logger.e('Failed to create answer: $e');
      rethrow;
    }
  }

  /// Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection.addCandidate(candidate);
      _logger.i('ICE candidate added');
    } catch (e) {
      _logger.e('Failed to add ICE candidate: $e');
    }
  }

  /// Set remote description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _peerConnection.setRemoteDescription(description);
      _logger.i('Remote description set');
    } catch (e) {
      _logger.e('Failed to set remote description: $e');
      rethrow;
    }
  }

  /// Setup peer connection event listeners
  void _setupPeerConnectionListeners() {
    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      _logger.d('ICE candidate: ${candidate.candidate}');
      // Handle ICE candidate (usually send via signaling server)
    };

    _peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      _logger.i('Connection state changed: $state');
    };

    _peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      _logger.i('ICE connection state changed: $state');
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      _logger.i('Remote track received: ${event.track.kind}');
    };
  }

  /// Close the peer connection
  Future<void> close() async {
    try {
      await stopLocalStream();
      await _peerConnection.close();
      _logger.i('WebRTC connection closed');
    } catch (e) {
      _logger.e('Failed to close WebRTC connection: $e');
    }
  }
}
