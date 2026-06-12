# Hướng dẫn Sử dụng Camera IP App

## Lần Đầu Tiên

### 1. Cài Đặt & Chạy Ứng Dụng

```bash
cd camera_app_ip
flutter pub get
flutter run
```

### 2. Đăng Ký Tài Khoản

1. Tap "Don't have an account? Sign Up"
2. Nhập:
   - **Display Name**: Tên hiển thị của bạn
   - **Email**: Email hợp lệ
   - **Password**: Mật khẩu (tối thiểu 6 ký tự)
3. Tap "Sign Up"
4. Chờ tài khoản được tạo

### 3. Đăng Nhập

Nếu đã có tài khoản:
1. Nhập Email
2. Nhập Password
3. Tap "Sign In"

## Quản Lý Camera

### Thêm Camera Mới

1. Ở màn hình chính, tap nút **+** (Floating Action Button)
2. Điền thông tin:
   - **Camera Name**: Tên camera (vd: "Front Door")
   - **RTSP URL**: Địa chỉ stream (vd: `rtsp://192.168.1.100:554/stream`)
   - **Username**: Username camera (nếu có)
   - **Password**: Password camera (nếu có)
   - **Location**: Vị trí (vd: "Cửa trước")
3. Tap "Add Camera"

### Xem Live Stream

1. Từ màn hình chính, tap vào camera muốn xem
2. Ứng dụng sẽ kết nối đến RTSP stream
3. Tap lại để quay lại danh sách

### Chỉnh Sửa Camera

1. Từ danh sách, tap nút **edit** (biểu tượng bút)
2. Cập nhật thông tin cần thiết
3. Tap "Update Camera"

### Xóa Camera

1. Từ danh sách, tap nút **edit** camera
2. Tap biểu tượng **delete** (thùng rác) ở góc trên cùng
3. Xác nhận xóa

## Tìm RTSP URL Camera

### Hikvision
```
rtsp://192.168.1.100:554/Streaming/Channels/101
rtsp://username:password@192.168.1.100:554/Streaming/Channels/101
```

### Dahua
```
rtsp://192.168.1.100:554/stream1
rtsp://username:password@192.168.1.100:554/stream1
```

### Axis Communications
```
rtsp://192.168.1.100/axis-media/media.amp?videocodec=h264
rtsp://username:password@192.168.1.100/axis-media/media.amp
```

### TP-Link Tapo
```
rtsp://192.168.1.100:554/stream
rtsp://username:password@192.168.1.100:554/stream
```

### Generic RTSP
```
rtsp://192.168.1.100:554
rtsp://192.168.1.100:554/stream0
rtsp://192.168.1.100:554/stream1
```

## Cách Tìm Địa Chỉ IP Camera

### Phương pháp 1: Từ Router
1. Mở web interface của router
2. Kiểm tra danh sách devices kết nối
3. Tìm camera trong danh sách

### Phương pháp 2: Dùng Mobile App Camera
1. Dùng ứng dụng chính thức của camera
2. Kiểm tra thông tin camera trong settings
3. Sẽ hiển thị IP address

### Phương pháp 3: Network Scanner
1. Download ứng dụng như "Advanced IP Scanner"
2. Scan network
3. Tìm camera trong danh sách

## Troubleshooting

### "Connection Error" khi xem camera

**Nguyên nhân & Giải Pháp:**

1. **IP/Port sai**
   - Kiểm tra IP camera đúng không
   - Port mặc định RTSP là 554
   - Thử kết nối từ máy tính dùng VLC

2. **Camera offline**
   - Kiểm tra camera có điện không
   - Kiểm tra kết nối mạng
   - Restart camera

3. **Username/Password sai**
   - Reset camera về default credentials
   - Kiểm tra lại password
   - Thử không nhập username/password

4. **Firewall chặn**
   - Kiểm tra firewall settings
   - Cho phép port 554 nếu cần
   - Thử kết nối từ máy khác

### "Invalid RTSP URL"

- URL phải bắt đầu bằng `rtsp://`
- Không được có http:// hoặc https://
- Kiểm tra lại format

### Ứng dụng crash khi xem video

- Kiểm tra điện thoại có RAM đủ không
- Đóng các ứng dụng khác
- Restart điện thoại
- Reinstall ứng dụng

### Không thể đăng nhập

- Kiểm tra internet connection
- Xác nhận email được register
- Thử reset password
- Kiểm tra firewall/proxy settings

## Mẹo & Thủ Thuật

### 1. Tối Ưu Hiệu Năng
- Dùng resolution thấp hơn nếu có lag
- Giảm số lượng camera xem cùng lúc
- Đóng các ứng dụng chạy background

### 2. Tiết Kiệm Dữ Liệu
- Xem camera qua WiFi khi có thể
- Hạn chế stream HD nếu dùng 4G
- Tắt video khi không sử dụng

### 3. An Toàn
- Dùng password mạnh cho camera
- Thường xuyên cập nhật firmware camera
- Không share RTSP URL trên internet công khai
- Dùng VPN nếu truy cập từ ngoài mạng nhà

## FAQ

**Q: Có thể xem camera từ ngoài mạng nhà không?**
A: Có, nhưng cần:
- Port forward RTSP port trên router (có rủi ro bảo mật)
- Hoặc dùng VPN vào mạng nhà
- Hoặc dùng dịch vụ cloud camera

**Q: Tại sao video lag?**
A: Có thể do:
- Mạng yếu
- Camera bitrate cao
- Điện thoại không đủ mạnh
- Quá nhiều camera xem cùng lúc

**Q: Có thể record video không?**
A: Chưa hỗ trợ hiện tại, nhưng sẽ thêm trong version tới.

**Q: Hỗ trợ bao nhiêu camera?**
A: Lý thuyết không giới hạn, nhưng hiệu năng phụ thuộc mạng & điện thoại.

**Q: Dữ liệu camera được lưu ở đâu?**
A: Lưu trên Firebase Firestore (cloud).

## Liên Hệ & Support

Nếu gặp vấn đề, vui lòng:
- Kiểm tra lại troubleshooting guide
- Restart ứng dụng
- Restart điện thoại
- Reinstall ứng dụng
