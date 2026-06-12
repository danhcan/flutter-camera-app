import 'package:flutter/material.dart';
import '../models/camera_model.dart';
import '../services/rtsp_player_service.dart';

class CameraPlayerScreen extends StatefulWidget {
  final CameraModel camera;

  const CameraPlayerScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  State<CameraPlayerScreen> createState() => _CameraPlayerScreenState();
}

class _CameraPlayerScreenState extends State<CameraPlayerScreen> {
  late RtspPlayerService _playerService;
  bool _isPlaying = false;
  bool _isConnecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _playerService = RtspPlayerService(widget.camera);
    _connectCamera();
  }

  Future<void> _connectCamera() async {
    setState(() => _isConnecting = true);
    try {
      await _playerService.initialize();
      setState(() => _isPlaying = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.camera.name),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to camera...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _connectCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isPlaying) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera disconnected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _connectCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Reconnect'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle,
              size: 80,
              color: Colors.green.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'RTSP Stream Playing',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.camera.rtspUrl,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
