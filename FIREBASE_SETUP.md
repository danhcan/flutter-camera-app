# Firebase Setup Guide

## Bước 1: Tạo Firebase Project

1. Truy cập https://console.firebase.google.com
2. Click "Add project"
3. Nhập tên project: `camera-app-ip`
4. Click "Create project"
5. Chọn "No, thanks" cho Google Analytics (optional)
6. Chờ project được tạo

## Bước 2: Setup Authentication

1. Vào "Authentication" trong Firebase Console
2. Click "Get started"
3. Chọn "Email/Password"
4. Enable "Email/Password"
5. Click "Save"

## Bước 3: Setup Firestore Database

1. Vào "Firestore Database"
2. Click "Create database"
3. Chọn "Start in test mode" (cho development)
4. Chọn region gần nhất
5. Click "Create"

### Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Cameras subcollection
      match /cameras/{cameraId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

## Bước 4: Download Google Services File

### Cho Android:

1. Vào Project Settings (⚙️ > Project settings)
2. Chọn tab "Your apps"
3. Chọn Android app
4. Click "Download google-services.json"
5. Đặt file vào: `android/app/google-services.json`

### Cho iOS (optional):

1. Chọn iOS app
2. Click "Download GoogleService-Info.plist"
3. Đặt file vào: `ios/Runner/GoogleService-Info.plist`

## Bước 5: Update firebase_options.dart

Copy credentials từ Firebase Console vào `lib/firebase_options.dart`:

1. Vào Project Settings > General
2. Tìm phần "Your apps" > Android
3. Copy các credentials:
   - API Key
   - App ID
   - Messaging Sender ID
   - Project ID
   - Storage Bucket

Dán vào file `firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: '1:YOUR_SENDER_ID:android:YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'camera-app-ip',
  storageBucket: 'camera-app-ip.appspot.com',
);
```

## Bước 6: Enable Required APIs

1. Vào Google Cloud Console: https://console.cloud.google.com
2. Chọn project của bạn
3. Enable các APIs:
   - Firebase Authentication API
   - Cloud Firestore API
   - Firebase Realtime Database API

## Bước 7: Test Kết Nối

```bash
flutter run
```

Thử:
1. Sign up account mới
2. Kiểm tra trong Firestore Console xem user được tạo
3. Thêm camera mới
4. Kiểm tra cameras collection trong Firestore

## Troubleshooting

### "google-services.json not found"
- Chắc chắn file được đặt trong `android/app/`
- Rebuild: `flutter clean && flutter pub get`

### Firebase authentication không work
- Kiểm tra Email/Password provider được enable
- Kiểm tra internet connection
- Kiểm tra google-services.json file

### Firestore permission denied
- Kiểm tra security rules
- Nếu development, có thể dùng test mode
- Production, cập nhật rules như trên

### CORS errors
- Không có vấn đề với Flutter mobile app
- Chỉ xảy ra với web app

## Security Best Practices

1. **Test Mode**: Chỉ dùng trong development
2. **Production**: Update security rules trước deploy
3. **Credentials**: Không commit `google-services.json`
4. **Environment**: Dùng environment variables cho sensitive data
5. **Validation**: Validate tất cả user input trước lưu Firebase

## Reference

- Firebase Docs: https://firebase.flutter.dev/
- Firestore Rules: https://firebase.google.com/docs/firestore/security/get-started
- Android Setup: https://firebase.google.com/docs/android/setup
