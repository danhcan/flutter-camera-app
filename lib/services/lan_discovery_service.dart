import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../models/camera_model.dart';

class DiscoveredCamera {
  final String ip;
  final int port;
  final String type; // rtsp, http, onvif
  String name;
  String? streamUrl;

  DiscoveredCamera({
    required this.ip,
    required this.port,
    required this.type,
    this.name = '',
    this.streamUrl,
  });
}

class LanDiscoveryService {
  static const List<int> _commonPorts = [554, 80, 8080, 37777, 34567, 1024, 81];
  static const _scanTimeout = Duration(milliseconds: 500);

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              addr.address.startsWith('192.168.') ||
              addr.address.startsWith('10.') ||
              addr.address.startsWith('172.16')) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  String _getSubnet(String ip) {
    final parts = ip.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.';
  }

  /// Scan LAN cho camera trên các port phổ biến
  Future<List<DiscoveredCamera>> scanLan({
    int concurrency = 50,
    Set<int>? ports,
  }) async {
    final localIp = await _getLocalIp();
    if (localIp == null) return [];

    final subnet = _getSubnet(localIp);
    final localLastOctet = int.tryParse(localIp.split('.').last) ?? 1;
    final targetPorts = ports ?? _commonPorts;

    final discovered = <DiscoveredCamera>[];
    final seen = <String>{};
    final completer = Completer<void>();
    int completed = 0;
    const totalHosts = 254; // .1 - .254
    final totalScans = totalHosts * targetPorts.length;

    void tryComplete() {
      if (completed >= totalScans && !completer.isCompleted) {
        completer.complete();
      }
    }

    // Giới hạn concurrent connections
    final semaphore = Semaphore(concurrency);

    for (int i = 1; i <= 254; i++) {
      if (i == localLastOctet) continue; // bỏ qua IP local

      final ip = '$subnet$i';

      for (final port in targetPorts) {
        unawaited(_scanIpPort(ip, port, semaphore).then((result) {
          if (result != null) {
            final key = '${result.ip}:${result.port}';
            if (!seen.contains(key)) {
              seen.add(key);
              discovered.add(result);
            }
          }
        }).whenComplete(() {
          completed++;
          tryComplete();
        }));
      }
    }

    // Timeout tổng thể 30 giây
    await completer.future.timeout(const Duration(seconds: 30), onTimeout: () {});

    return discovered;
  }

  Future<DiscoveredCamera?> _scanIpPort(
    String ip,
    int port,
    Semaphore semaphore,
  ) async {
    return semaphore.acquire(() async {
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: _scanTimeout,
        );
        socket.destroy();

        // Xác định loại dựa trên port
        String type;
        switch (port) {
          case 554:
            type = 'rtsp';
            break;
          case 80:
          case 8080:
          case 81:
            type = 'http';
            break;
          case 37777:
          case 34567:
            type = 'onvif';
            break;
          default:
            type = 'unknown';
        }

        // Thử lấy tên thiết bị qua HTTP nếu là port web
        String name = '';
        if (port == 80 || port == 8080 || port == 81) {
          name = await _getDeviceName(ip, port);
        }

        String? streamUrl;
        if (type == 'rtsp') {
          streamUrl = 'rtsp://$ip:554/stream';
        } else if (type == 'http') {
          streamUrl = 'http://$ip:$port/video';
          // Một số path phổ biến
          final altPaths = [
            'http://$ip:$port/stream',
            'http://$ip:$port/videostream.cgi',
            'http://$ip:$port/mjpg/video.mjpg',
            'http://$ip:$port/cgi-bin/camera',
          ];
          for (final altUrl in altPaths) {
            if (await _testHttpUrl(altUrl)) {
              streamUrl = altUrl;
              break;
            }
          }
        }

        return DiscoveredCamera(
          ip: ip,
          port: port,
          type: type,
          name: name.isNotEmpty ? name : 'Camera $ip',
          streamUrl: streamUrl,
        );
      } catch (_) {
        return null;
      }
    });
  }

  Future<String> _getDeviceName(String ip, int port) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final request = await client.getUrl(Uri.parse('http://$ip:$port/'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).first;
      client.close();

      // Parse title từ HTML
      final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false).firstMatch(body);
      if (titleMatch != null) {
        return titleMatch.group(1)!.trim();
      }
    } catch (_) {}
    return '';
  }

  Future<bool> _testHttpUrl(String url) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Semaphore để giới hạn số lượng concurrent operations
class Semaphore {
  final int _max;
  int _count = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this._max);

  Future<T> acquire<T>(Future<T> Function() fn) async {
    if (_count >= _max) {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;
    }

    _count++;
    try {
      return await fn();
    } finally {
      _count--;
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      }
    }
  }
}
