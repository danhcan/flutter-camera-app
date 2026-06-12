import 'package:video_player/video_player.dart';
import '../models/camera_model.dart';

class RtspPlayerService {
  final CameraModel camera;
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  RtspPlayerService(this.camera);

  bool get isInitialized => _isInitialized;
  VideoPlayerController get controller => _controller;

  Future<void> initialize() async {
    try {
      // Build RTSP URL with credentials if provided
      String url = camera.rtspUrl;
      
      if (camera.username.isNotEmpty && camera.password.isNotEmpty) {
        // Insert credentials into RTSP URL
        // rtsp://user:pass@host/stream
        url = camera.rtspUrl.replaceFirst(
          'rtsp://',
          'rtsp://${camera.username}:${camera.password}@',
        );
      }

      _controller = VideoPlayerController.network(
        url,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _controller.initialize();
      await _controller.play();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RTSP stream: $e');
    }
  }

  Future<void> play() async {
    if (_isInitialized) {
      await _controller.play();
    }
  }

  Future<void> pause() async {
    if (_isInitialized) {
      await _controller.pause();
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _controller.dispose();
      _isInitialized = false;
    }
  }

  Duration get duration => _controller.value.duration;
  Duration get position => _controller.value.position;
  bool get isPlaying => _controller.value.isPlaying;
  bool get hasError => _controller.value.hasError;
}
