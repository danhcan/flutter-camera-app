import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera_model.dart';

class VideoPlayerService {
  final CameraModel camera;
  late VlcPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  VideoPlayerService(this.camera);

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  VlcPlayerController get controller => _controller;

  static String buildRtspUrl({
    required String rtspUrl,
    String username = '',
    String password = '',
  }) {
    final cleanUrl = rtspUrl.trim();

    if (username.trim().isEmpty || password.trim().isEmpty) {
      return cleanUrl;
    }

    // If URL already contains credentials, keep as-is.
    // Example: rtsp://user:pass@host:554/stream
    final withoutScheme = cleanUrl.replaceFirst('rtsp://', '');
    if (withoutScheme.contains('@')) {
      return cleanUrl;
    }

    return cleanUrl.replaceFirst(
      'rtsp://',
      'rtsp://${Uri.encodeComponent(username.trim())}:${Uri.encodeComponent(password.trim())}@',
    );
  }

  String get playableUrl => buildRtspUrl(
        rtspUrl: camera.rtspUrl,
        username: camera.username,
        password: camera.password,
      );

  Future<void> initialize() async {
    try {
      _controller = VlcPlayerController.network(
        playableUrl,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcOption.networkCaching(1500),
            VlcOption.liveCaching(1500),
            VlcOption.rtspTcp,
          ]),
          video: VlcVideoOptions([
            VlcOption.videoTitleShow(false),
          ]),
        ),
      );

      await _controller.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Không khởi tạo được RTSP player: $e');
    }
  }

  Future<void> play() async {
    if (!_isInitialized) {
      throw Exception('Player chưa được khởi tạo');
    }
    await _controller.play();
    _isPlaying = true;
  }

  Future<void> pause() async {
    if (!_isInitialized) return;
    await _controller.pause();
    _isPlaying = false;
  }

  Future<void> reconnect() async {
    await dispose();
    await initialize();
    await play();
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;
    try {
      await _controller.stop();
      await _controller.dispose();
    } catch (_) {
      // Ignore dispose errors because VLC may already be released.
    } finally {
      _isInitialized = false;
      _isPlaying = false;
    }
  }

  static Future<String?> testConnection({
    required String rtspUrl,
    String username = '',
    String password = '',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    VlcPlayerController? controller;
    try {
      final url = buildRtspUrl(
        rtspUrl: rtspUrl,
        username: username,
        password: password,
      );

      controller = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcOption.networkCaching(1000),
            VlcOption.liveCaching(1000),
            VlcOption.rtspTcp,
          ]),
        ),
      );

      await controller.initialize().timeout(timeout);
      await controller.play();
      await Future.delayed(const Duration(seconds: 2));

      final value = controller.value;
      if (value.hasError) {
        return value.errorDescription ?? 'Không kết nối được RTSP stream';
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      try {
        await controller?.stop();
        await controller?.dispose();
      } catch (_) {}
    }
  }
}
