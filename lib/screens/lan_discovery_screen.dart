import 'dart:async';
import 'package:flutter/material.dart';
import '../models/camera_model.dart';
import '../services/lan_discovery_service.dart';
import '../providers/camera_provider.dart';
import 'package:provider/provider.dart';

class LanDiscoveryScreen extends StatefulWidget {
  const LanDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<LanDiscoveryScreen> createState() => _LanDiscoveryScreenState();
}

class _LanDiscoveryScreenState extends State<LanDiscoveryScreen> {
  final _discoveryService = LanDiscoveryService();
  List<DiscoveredCamera> _discovered = [];
  bool _isScanning = false;
  String _status = '';
  int _progress = 0;

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _discovered = [];
      _status = 'Đang quét mạng LAN...';
      _progress = 0;
    });

    // Animation progress
    final progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _progress++;
          final dots = List.filled(_progress % 4, '.').join();
          _status = 'Đang quét mạng LAN$dots';
        });
      }
    });

    try {
      final results = await _discoveryService.scanLan(concurrency: 80);
      setState(() {
        _discovered = results;
        _status = results.isEmpty ? 'Không tìm thấy camera nào' : 'Tìm thấy ${results.length} thiết bị';
      });
    } catch (e) {
      _status = 'Lỗi: $e';
    } finally {
      progressTimer.cancel();
      setState(() => _isScanning = false);
    }
  }

  Future<void> _addCamera(DiscoveredCamera cam) async {
    if (!mounted) return;

    // Map stream type
    StreamType streamType;
    switch (cam.type) {
      case 'rtsp':
        streamType = StreamType.rtsp;
        break;
      case 'http':
        streamType = StreamType.http;
        break;
      case 'onvif':
        streamType = StreamType.onvif;
        break;
      default:
        streamType = StreamType.rtsp;
    }

    final streamUrl = cam.streamUrl ?? (cam.type == 'rtsp' 
        ? 'rtsp://${cam.ip}:${cam.port}/stream'
        : 'http://${cam.ip}:${cam.port}');

    try {
      final provider = context.read<CameraProvider>();
      await provider.addCamera(
        name: cam.name.isNotEmpty ? cam.name : 'Camera ${cam.ip}',
        rtspUrl: streamUrl,
        streamType: streamType,
        username: '',
        password: '',
        location: 'LAN',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ${cam.name}')),
        );
        setState(() {
          _discovered.remove(cam);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét camera LAN'),
        actions: [
          if (!_isScanning)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                if (!_isScanning && _discovered.isEmpty) ...[
                  Icon(Icons.wifi_find, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Quét toàn bộ mạng LAN để tìm camera IP\n(port 554, 80, 8080, 37777...)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.search),
                    label: const Text('Bắt đầu quét'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                  ),
                ],
                if (_isScanning) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(_status),
                ],
                if (!_isScanning && _discovered.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _status,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chạm vào camera để thêm',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: _discovered.isEmpty
                ? Center(
                    child: Text(
                      _isScanning ? '' : 'Bấm "Bắt đầu quét" để dò camera trong mạng LAN',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _discovered.length,
                    itemBuilder: (context, index) {
                      final cam = _discovered[index];
                      return _CameraCard(
                        camera: cam,
                        onAdd: () => _addCamera(cam),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CameraCard extends StatelessWidget {
  final DiscoveredCamera camera;
  final VoidCallback onAdd;

  const _CameraCard({
    required this.camera,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;
    switch (camera.type) {
      case 'rtsp':
        typeColor = Colors.blue;
        typeIcon = Icons.link;
        break;
      case 'http':
        typeColor = Colors.orange;
        typeIcon = Icons.wifi;
        break;
      case 'onvif':
        typeColor = Colors.green;
        typeIcon = Icons.device_hub;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.devices;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(camera.name.isNotEmpty ? camera.name : 'Camera ${camera.ip}'),
        subtitle: Text('${camera.ip}:${camera.port}  —  ${camera.type.toUpperCase()}'),
        trailing: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Thêm'),
        ),
      ),
    );
  }
}
