import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera_model.dart';
import '../services/video_player_service.dart';

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
  late VideoPlayerService _playerService;
  bool _isConnecting = false;
  String? _error;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _playerService = VideoPlayerService(widget.camera);
    _connectCamera();
  }

  Future<void> _connectCamera() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      await _playerService.initialize();
      await _playerService.play();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _reconnectCamera() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      await _playerService.reconnect();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_playerService.isPlaying) {
        await _playerService.pause();
      } else {
        await _playerService.play();
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi player: $e')),
      );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.camera.name),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Thông tin camera',
            icon: const Icon(Icons.info_outline),
            onPressed: _showCameraInfo,
          ),
          IconButton(
            tooltip: 'Kết nối lại',
            icon: const Icon(Icons.refresh),
            onPressed: _reconnectCamera,
          ),
        ],
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
            Text(
              'Đang kết nối camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Không xem được camera',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              Text(
                'Gợi ý: kiểm tra URL, username/password, port forward WAN, firewall, hoặc thử URL này bằng VLC trước.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                'Kiểu stream: ${widget.camera.streamType.name.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reconnectCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_playerService.isInitialized) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _connectCamera,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Kết nối camera'),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: VlcPlayer(
              controller: _playerService.controller,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          if (_showControls)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: IconButton(
                    iconSize: 84,
                    color: Colors.white,
                    icon: Icon(
                      _playerService.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
            ),
          if (_showControls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: Icon(
                        _playerService.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.camera.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.camera.rtspUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.refresh),
                      onPressed: _reconnectCamera,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCameraInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.camera.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Vị trí', widget.camera.location),
            _buildInfoRow('Kiểu stream', widget.camera.streamType.name.toUpperCase()),
            _buildInfoRow('URL', widget.camera.rtspUrl),
            _buildInfoRow(
              'Username',
              widget.camera.username.isEmpty ? '(không có)' : widget.camera.username,
            ),
            _buildInfoRow('WAN/LAN', _guessNetworkType(widget.camera.rtspUrl)),
            _buildInfoRow(
              'Trạng thái',
              _playerService.isPlaying ? 'Đang phát' : 'Đang tạm dừng',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }

  String _guessNetworkType(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? '';
    if (host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host)) {
      return 'LAN IP / VPN';
    }
    return 'WAN IP / Public domain';
  }
}
