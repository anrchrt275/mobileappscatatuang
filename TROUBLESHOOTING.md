# Troubleshooting Login Connection Issues

## Masalah Utama
"Login Gagal - Terjadi kesalahan koneksi" biasanya disebabkan oleh:

### 1. Konfigurasi API URL
Aplikasi menggunakan `ApiConfig` untuk mendeteksi platform secara otomatis:
- **Android Emulator**: `http://10.0.2.2/api`
- **Web Testing**: `http://localhost/api`
- **Physical Device**: `http://192.168.1.100/api` (ubah ke IP PC Anda)

### 2. Server XAMPP
Pastikan:
- Apache dan MySQL running di XAMPP
- Database `catatuang_db` sudah dibuat
- File API ada di folder `htdocs/api`

### 3. Database Setup
Jalankan SQL berikut di phpMyAdmin:
```sql
-- Import file: api/setup_database.sql
```

## Testing Steps

### 1. Test Database Connection
Buka browser: `http://localhost/api/test_connection.php`

### 2. Test API Manual
Gunakan Postman/curl untuk test:
```bash
curl -X POST http://localhost/api/login.php \
  -d "email=test@test.com&password=test"
```

### 3. Test di Flutter
Untuk physical device, update IP di `ApiConfig`:
```dart
// Di api_config.dart, ganti IP PC Anda
return 'http://192.168.1.100/api'; // contoh IP
```

## Common Solutions

### Server Not Running
```bash
# Start XAMPP services
sudo /opt/lampp/lampp start
```

### Wrong IP Address
1. Buka Command Prompt
2. Run: `ipconfig`
3. Cari "IPv4 Address" (biasanya 192.168.x.x)
4. Update di `ApiConfig`

### Database Not Created
1. Buka phpMyAdmin: `http://localhost/phpmyadmin`
2. Import file `api/setup_database.sql`

### CORS Issues
CORS sudah diatur di `config.php` dengan:
```php
header("Access-Control-Allow-Origin: *");
```

## Error Messages & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Tidak dapat terhubung ke server" | Server offline | Start XAMPP Apache |
| "Server tidak dapat ditemukan" | Wrong IP/URL | Check API URL |
| "Koneksi timeout" | Network issues | Check internet connection |
| "Response server tidak valid" | PHP error | Check PHP logs |

## Development Tips

### Untuk Testing
```dart
// Override API URL untuk testing
ApiConfig.setBaseUrl('http://localhost/api');
```

### Debug Mode
```dart
// Enable logging
import 'package:flutter/foundation.dart';
if (kDebugMode) {
  print('API URL: ${ApiConfig.effectiveBaseUrl}');
}
```
