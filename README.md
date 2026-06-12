# Camera IP App - Flutter

Ứng dụng Flutter để xem live stream từ nhiều camera RTSP/ONVIF trên Android với Firebase backend.

## Tính năng

- ✅ Xem live stream từ nhiều camera RTSP
- ✅ Quản lý danh sách camera với Firebase Firestore
- ✅ Xác thực người dùng với Firebase Auth
- ✅ Giao diện grid để xem tất cả camera
- ✅ Chi tiết camera và chỉnh sửa thông tin
- ✅ Hỗ trợ ONVIF discovery (cơ bản)
- ✅ Reconnection tự động
- ✅ Dark mode support

## Architecture

```
lib/
├── main.dart              # Entry point
├── firebase_options.dart  # Firebase config
├── models/
│   ├── camera_model.dart
│   └── user_model.dart
├── providers/             # State management (Provider)
│   ├── auth_provider.dart
│   └── camera_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── camera_grid_screen.dart
│   ├── camera_player_screen.dart
│   ├── camera_detail_screen.dart
│   └── add_camera_screen.dart
└── services/
    ├── rtsp_player_service.dart
    └── onvif_discovery_service.dart
```

## Setup Firebase

1. Tạo Firebase project tại https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Download `google-services.json` từ Firebase Console
5. Đặt file vào `android/app/`
6. Update `firebase_options.dart` với credentials của bạn

## Firestore Structure

```
users/
├── {userId}/
│   ├── uid
│   ├── email
│   ├── displayName
│   ├── photoUrl
│   ├── createdAt
│   ├── updatedAt
│   └── cameras/
│       └── {cameraId}/
│           ├── id
│           ├── name
│           ├── rtspUrl
│           ├── username
│           ├── password
│           ├── location
│           ├── isActive
│           ├── createdAt
│           └── updatedAt
```

## Cài đặt Dependencies

```bash
flutter pub get
```

## Chạy Ứng dụng

### Development
```bash
flutter run
```

### Release
```bash
flutter build apk --release
```

## RTSP URL Format

```
rtsp://host:port/stream
rtsp://username:password@host:port/stream
```

### Ví dụ

- Hikvision: `rtsp://192.168.1.100:554/Streaming/Channels/101`
- Dahua: `rtsp://192.168.1.100:554/stream1`
- Generic: `rtsp://192.168.1.100/stream`

## Troubleshooting

### Không thể kết nối RTSP
- Kiểm tra IP camera và port (thường là 554)
- Kiểm tra username/password
- Kiểm tra firewall
- Xác nhận camera hỗ trợ RTSP streaming

### Firebase không khởi động
- Kiểm tra `google-services.json` được đặt đúng
- Rebuild project: `flutter clean && flutter pub get`
- Kiểm tra internet connection

### Video không phát
- Kiểm tra RTSP URL format
- Xác nhận camera đang online
- Thử kết nối bằng VLC player trước

## Tính năng sắp tới

- [ ] Hỗ trợ HLS/HTTP streaming
- [ ] Recording video từ camera
- [ ] Motion detection alerts
- [ ] Two-way audio
- [ ] WebRTC support
- [ ] Multi-window layout
- [ ] Advanced ONVIF discovery

## License

MIT License

## Support

Để báo cáo lỗi hoặc yêu cầu tính năng, vui lòng tạo issue.
