import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/camera_model.dart';
import '../providers/camera_provider.dart';
import '../services/video_player_service.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({Key? key}) : super(key: key);

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streamUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isTestingRtsp = false;
  StreamType _streamType = StreamType.rtsp;

  @override
  void dispose() {
    _nameController.dispose();
    _streamUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String get _protocolHint {
    switch (_streamType) {
      case StreamType.rtsp:
        return 'rtsp://192.168.1.100:554/stream';
      case StreamType.http:
        return 'http://103.82.192.121:8080/video';
      case StreamType.onvif:
        return 'http://192.168.1.100:8080/onvif/device_service';
    }
  }

  String get _labelText {
    switch (_streamType) {
      case StreamType.rtsp:
        return 'RTSP URL';
      case StreamType.http:
        return 'HTTP Stream URL';
      case StreamType.onvif:
        return 'ONVIF URL';
    }
  }

  IconData get _prefixIcon {
    switch (_streamType) {
      case StreamType.rtsp:
        return Icons.link;
      case StreamType.http:
        return Icons.wifi;
      case StreamType.onvif:
        return Icons.device_hub;
    }
  }

  Future<void> _handleTestStream() async {
    final url = _streamUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập URL trước khi test')),
      );
      return;
    }
    if (_streamType == StreamType.rtsp && !url.startsWith('rtsp://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RTSP URL phải bắt đầu với rtsp://')),
      );
      return;
    }

    setState(() => _isTestingRtsp = true);
    final error = await VideoPlayerService.testConnection(
      rtspUrl: url,
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isTestingRtsp = false);

    final typeLabel = _streamType.name.toUpperCase();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(error == null ? 'Test thành công' : 'Test thất bại'),
        content: Text(
          error == null
              ? 'Ứng dụng đã kết nối được stream. Bạn có thể lưu camera.'
              : 'Không kết nối được $typeLabel stream.\n\n$error\n\nGợi ý:\n- Test URL bằng VLC trên máy tính\n- Kiểm tra username/password\n- Camera WAN IP: kiểm tra port forward/firewall\n- Camera HTTP thường dùng MJPEG trên port 8080',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập URL';
    }
    switch (_streamType) {
      case StreamType.rtsp:
        if (!value.startsWith('rtsp://')) {
          return 'URL phải bắt đầu với rtsp://';
        }
        break;
      case StreamType.http:
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          return 'URL phải bắt đầu với http:// hoặc https://';
        }
        break;
      case StreamType.onvif:
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          return 'URL phải bắt đầu với http:// hoặc https://';
        }
        break;
    }
    return null;
  }

  Future<void> _handleAddCamera() async {
    if (!_formKey.currentState!.validate()) return;

    final cameraProvider = context.read<CameraProvider>();

    try {
      await cameraProvider.addCamera(
        name: _nameController.text.trim(),
        rtspUrl: _streamUrlController.text.trim(),
        streamType: _streamType,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm camera thành công')),
        );
        Navigator.pop(context);
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
        title: const Text('Thêm camera'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên camera',
                  prefixIcon: const Icon(Icons.videocam),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên camera';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stream type selector
              SegmentedButton<StreamType>(
                segments: const [
                  ButtonSegment(
                    value: StreamType.rtsp,
                    label: Text('RTSP'),
                    icon: Icon(Icons.link),
                  ),
                  ButtonSegment(
                    value: StreamType.http,
                    label: Text('HTTP'),
                    icon: Icon(Icons.wifi),
                  ),
                  ButtonSegment(
                    value: StreamType.onvif,
                    label: Text('ONVIF'),
                    icon: Icon(Icons.device_hub),
                  ),
                ],
                selected: {_streamType},
                onSelectionChanged: (selected) {
                  setState(() => _streamType = selected.first);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _streamUrlController,
                decoration: InputDecoration(
                  labelText: _labelText,
                  prefixIcon: Icon(_prefixIcon),
                  hintText: _protocolHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 12),
              if (_streamType == StreamType.http)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade700),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'HTTP Stream dùng cho camera WAN IP. '
                          'URL thường có dạng: http://wan_ip:port/video hoặc /stream',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_streamType == StreamType.onvif)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade700),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.greenAccent, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ONVIF tự động dò camera trên mạng LAN. Cần username/password đăng nhập camera.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username (tuỳ chọn)',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password (tuỳ chọn)',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Vị trí',
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: 'VD: Cửa trước, Phòng khách',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isTestingRtsp ? null : _handleTestStream,
                icon: _isTestingRtsp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(_isTestingRtsp ? 'Đang test...' : 'Test stream trước khi lưu'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<CameraProvider>(
                builder: (context, cameraProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: cameraProvider.isLoading ? null : _handleAddCamera,
                    icon: cameraProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Thêm camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
