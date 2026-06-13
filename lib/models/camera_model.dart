import 'package:cloud_firestore/cloud_firestore.dart';

enum StreamType { rtsp, http, onvif }

class CameraModel {
  final String id;
  final String name;
  final String rtspUrl;
  final StreamType streamType;
  final String username;
  final String password;
  final String location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CameraModel({
    required this.id,
    required this.name,
    required this.rtspUrl,
    this.streamType = StreamType.rtsp,
    required this.username,
    required this.password,
    required this.location,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'streamUrl': rtspUrl,
      'streamType': streamType.name,
      'username': username,
      'password': password,
      'location': location,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CameraModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CameraModel(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? 'Unknown',
      rtspUrl: data['streamUrl'] ?? data['rtspUrl'] ?? '',
      streamType: StreamType.values.firstWhere(
        (e) => e.name == data['streamType'],
        orElse: () => StreamType.rtsp,
      ),
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CameraModel copyWith({
    String? id,
    String? name,
    String? rtspUrl,
    StreamType? streamType,
    String? username,
    String? password,
    String? location,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CameraModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rtspUrl: rtspUrl ?? this.rtspUrl,
      streamType: streamType ?? this.streamType,
      username: username ?? this.username,
      password: password ?? this.password,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
