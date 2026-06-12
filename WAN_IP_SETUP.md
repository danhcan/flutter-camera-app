# WAN IP / RTSP Camera Guide

Ứng dụng hỗ trợ cả:

- LAN IP: `rtsp://192.168.1.100:554/stream`
- WAN IP/Public IP: `rtsp://203.113.45.120:8554/stream`
- Domain/DDNS: `rtsp://myhome.ddns.net:8554/stream`

## Muốn dùng WAN IP cần gì?

Camera thường nằm trong mạng nhà với IP nội bộ như `192.168.1.100`. Điện thoại ở ngoài mạng sẽ không vào thẳng IP này được. Bạn cần một trong các cách:

## Cách 1: Port Forward trên Router

Ví dụ camera RTSP trong nhà:

```text
Camera LAN IP: 192.168.1.100
RTSP port camera: 554
Router WAN IP: 203.113.45.120
External port bạn chọn: 8554
```

Trong router cấu hình:

```text
External port 8554 -> 192.168.1.100:554
Protocol: TCP hoặc TCP/UDP
```

Sau đó dùng URL trong app:

```text
rtsp://203.113.45.120:8554/stream
```

Nếu có tài khoản camera:

```text
rtsp://user:password@203.113.45.120:8554/stream
```

Hoặc nhập user/password riêng trong form app.

## Cách 2: DDNS

Nếu WAN IP hay thay đổi, dùng DDNS như No-IP/DuckDNS.

Ví dụ:

```text
rtsp://myhome.duckdns.org:8554/stream
```

## Cách 3: VPN (khuyên dùng)

An toàn hơn port forward. Dùng WireGuard/OpenVPN/Tailscale. Khi điện thoại vào VPN, bạn dùng LAN IP như ở nhà:

```text
rtsp://192.168.1.100:554/stream
```

## Test trước khi lưu

Trong app đã có nút:

```text
Test RTSP trước khi lưu
```

Nếu test lỗi, hãy kiểm tra:

1. URL có bắt đầu bằng `rtsp://` không
2. Đúng port chưa
3. Username/password đúng chưa
4. Port forward router đã đúng chưa
5. Camera có bật RTSP chưa
6. Thử mở bằng VLC trước

## Bảo mật

Không nên mở port 554 trực tiếp ra internet nếu không cần. Nếu port forward, nên:

- Dùng password camera mạnh
- Đổi external port khác 554, ví dụ 8554/9554
- Update firmware camera
- Tốt nhất dùng VPN
