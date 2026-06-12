import 'package:dio/dio.dart';
import '../models/camera_model.dart';

class OnvifDevice {
  final String name;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final List<String> streamUris;

  OnvifDevice({
    required this.name,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.streamUris,
  });
}

class OnvifDiscoveryService {
  final Dio _dio = Dio();
  static const String _wsDiscoveryMulticast = '239.255.255.250:3702';

  Future<List<OnvifDevice>> discoverDevices() async {
    List<OnvifDevice> devices = [];
    
    try {
      // Note: Actual WS-Discovery implementation would require
      // multicast UDP which is platform-specific.
      // This is a placeholder for ONVIF discovery via HTTP scan
      
      // In a real implementation, you would:
      // 1. Use WS-Discovery to find devices on network
      // 2. Probe for ONVIF services
      // 3. Query device information
      
      return devices;
    } catch (e) {
      throw Exception('Failed to discover ONVIF devices: $e');
    }
  }

  Future<OnvifDevice?> probeDevice(String ipAddress, {int port = 8080}) async {
    try {
      final response = await _dio.get(
        'http://$ipAddress:$port/onvif/device_service',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Parse ONVIF response (simplified)
        return OnvifDevice(
          name: 'Camera at $ipAddress',
          manufacturer: 'Unknown',
          model: 'Unknown',
          serialNumber: 'Unknown',
          streamUris: [],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getStreamUris(
    String ipAddress, {
    String username = '',
    String password = '',
    int port = 8080,
  }) async {
    try {
      List<String> uris = [];

      // Try common RTSP stream paths
      final commonPaths = [
        'rtsp://$ipAddress/stream1',
        'rtsp://$ipAddress/stream0',
        'rtsp://$ipAddress/ch1/main/av_stream',
        'rtsp://$ipAddress/Streaming/Channels/101',
      ];

      for (String uri in commonPaths) {
        try {
          final testUri = username.isNotEmpty
              ? uri.replaceFirst('rtsp://', 'rtsp://$username:$password@')
              : uri;

          // Attempt to connect (with timeout)
          await _testRtspConnection(testUri);
          uris.add(uri);
        } catch (e) {
          // Try next path
        }
      }

      return uris;
    } catch (e) {
      throw Exception('Failed to get stream URIs: $e');
    }
  }

  Future<void> _testRtspConnection(String uri) async {
    // Simplified RTSP connection test
    // In production, use proper RTSP client
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> dispose() async {
    _dio.close();
  }
}
