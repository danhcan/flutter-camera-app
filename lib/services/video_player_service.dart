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

  String get _protocol {
    switch (camera.streamType) {
      case StreamType.rtsp:
        return 'rtsp://';
      case StreamType.http:
        return 'http://';
      case StreamType.onvif:
        return 'http://';
    }
  }

  String get playableUrl {
    final cleanUrl = camera.rtspUrl.trim();
    final username = camera.username.trim();
    final password = camera.password.trim();

    if (username.isEmpty || password.isEmpty) return cleanUrl;

    // Already has credentials
    final withoutScheme = cleanUrl.startsWith('${_protocol}') 
        ? cleanUrl.substring(_protocol.length)
        : cleanUrl;
    if (withoutScheme.contains('@')) return cleanUrl;

    return cleanUrl.replaceFirst(
      _protocol,
      '${_protocol}${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@',
    );
  }

  List<String> get _extraOptions {
    switch (camera.streamType) {
      case StreamType.rtsp:
        return [
          VlcAdvancedOptions.networkCaching(1500),
          VlcAdvancedOptions.liveCaching(1500),
          '--rtsp-tcp',
        ];
      case StreamType.http:
        return [
          VlcAdvancedOptions.networkCaching(2000),
          '--http-reconnect',
        ];
      case StreamType.onvif:
        return [
          VlcAdvancedOptions.networkCaching(1500),
          '--rtsp-tcp',
        ];
    }
  }

  Future<void> initialize() async {
    try {
      _controller = VlcPlayerController.network(
        playableUrl,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions(_extraOptions),
          video: VlcVideoOptions([
            '--video-title-show=0',
          ]),
        ),
      );

      await _controller.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Không khởi tạo được player: $e');
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
    } catch (_) {}
    _isInitialized = false;
    _isPlaying = false;
  }

  static Future<String?> testConnection({
    required String rtspUrl,
    String username = '',
    String password = '',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    VlcPlayerController? controller;
    try {
      final cleanUrl = rtspUrl.trim();
      final url = (username.isEmpty || password.isEmpty)
          ? cleanUrl
          : cleanUrl.replaceFirst(
              cleanUrl.startsWith('rtsp://') ? 'rtsp://' : 'http://',
              '${cleanUrl.startsWith('rtsp://') ? 'rtsp://' : 'http://'}'
              '${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@',
            );

      controller = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(1000),
            VlcAdvancedOptions.liveCaching(1000),
            if (url.startsWith('rtsp://')) '--rtsp-tcp',
            if (url.startsWith('http://')) '--http-reconnect',
          ]),
        ),
      );

      await controller.initialize().timeout(timeout);
      await controller.play();
      await Future.delayed(const Duration(seconds: 2));

      final value = controller.value;
      if (value.hasError) {
        return value.errorDescription ?? 'Không kết nối được stream';
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
