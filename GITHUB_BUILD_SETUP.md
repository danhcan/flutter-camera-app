# GitHub Actions Build Guide

## 🚀 Cách Hoạt Động

Workflow này tự động build APK mỗi khi:
1. ✅ Push code lên branch `main`
2. ✅ Tạo Pull Request
3. ✅ Click "Run workflow" manually

## 📋 Setup (QUAN TRỌNG)

### Bước 1: Encode google-services.json

Vì `google-services.json` nằm trong `.gitignore` (bảo mật), bạn cần encode nó.

#### Option A: PowerShell (Windows)
```powershell
$content = [System.IO.File]::ReadAllBytes("D:\camera_app_ip\android\app\google-services.json")
$base64 = [System.Convert]::ToBase64String($content)
Write-Host $base64
```

Copy output và lưu lại.

#### Option B: Online Tool
1. Truy cập: https://www.base64encode.org/
2. Upload file `google-services.json`
3. Click "Encode"
4. Copy kết quả

#### Option C: Linux/Mac
```bash
cat android/app/google-services.json | base64
```

### Bước 2: Tạo GitHub Secret

1. Truy cập GitHub repo: https://github.com/danhcan/flutter-camera-app
2. Vào **Settings** > **Secrets and variables** > **Actions**
3. Click **"New repository secret"**
4. Điền:
   - **Name**: `GOOGLE_SERVICES_JSON`
   - **Value**: Paste Base64 string từ Bước 1
5. Click **"Add secret"**

### Bước 3: Test Workflow

1. Truy cập: https://github.com/danhcan/flutter-camera-app/actions
2. Chọn workflow **"Build APK"**
3. Click **"Run workflow"** > **"Run workflow"**
4. Chờ build hoàn thành (khoảng 10-15 phút)

## 📥 Tải APK

### Sau khi build thành công:

1. Vào **Actions** tab
2. Chọn workflow run mới nhất
3. Scroll xuống **"Artifacts"**
4. Download **"app-release"**
5. Giải nén, lấy file `app-release.apk`

## 🔄 Tự động Build

Mỗi lần bạn push code:
```bash
git add .
git commit -m "Update: new features"
git push
```

Workflow sẽ tự động chạy và build APK!

## ✅ Các Tính Năng Workflow

- ✅ Build APK Release
- ✅ Upload artifact (30 ngày)
- ✅ Tạo GitHub Release khi tag
- ✅ Hỗ trợ manual trigger

## 📌 Tạo Release Version

Để tạo release với tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

APK sẽ được upload tự động vào Releases!

## ⚠️ Troubleshooting

### Build fail: "google-services.json not found"
- Kiểm tra Secret `GOOGLE_SERVICES_JSON` đã được tạo chưa
- Kiểm tra Base64 string có đúng không

### Build fail: "Flutter not found"
- Workflow sẽ tự động cài Flutter
- Chờ action hoàn thành

### APK download failed
- Kiểm tra build passed (màu xanh ✓)
- Chờ 5 phút sau khi build xong
- Refresh trang

## 📚 Docs

- Flutter CI/CD: https://flutter.dev/docs/deployment/cd
- GitHub Actions: https://docs.github.com/en/actions
