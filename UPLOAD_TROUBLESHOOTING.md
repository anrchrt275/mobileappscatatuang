# Image Upload Troubleshooting Guide

## Problem: "Failed to fetch" Error when uploading profile image

## Root Cause
The API endpoint `http://localhost/praktikmcuas/api/upload_profile_image.php` is not accessible from the Flutter app.

## Solutions to Try

### 1. **Check XAMPP Services**
Make sure both Apache and MySQL are running in XAMPP Control Panel.

### 2. **Verify API is Accessible**
Open your web browser and test these URLs:
- `http://localhost/praktikmcuas/api/test.php` - Should show "API Server is working!"
- `http://localhost/praktikmcuas/api/config.php` - Should be blank (no errors)

### 3. **Check Database Connection**
Ensure the database `catatuang_db` exists and the `users` table has the `profile_image` column.

### 4. **Verify Uploads Directory**
Make sure the `uploads` folder exists at `c:\xampp\htdocs\praktikmcuas\uploads\` and has write permissions.

### 5. **For Web Platform Issues**
If running on web browser, you might need to:
- Use your computer's IP address instead of localhost
- Update `ApiConfig.baseUrl` to use your IP (e.g., `http://192.168.1.100/praktikmcuas/api`)

### 6. **Check PHP Error Logs**
Look at XAMPP logs: `C:\xampp\apache\logs\error.log`

### 7. **Test API Directly**
Create a simple HTML form to test the upload endpoint directly.

## Quick Fix Steps

1. **Start XAMPP**: Launch XAMPP Control Panel and start Apache & MySQL
2. **Test API**: Visit `http://localhost/praktikmcuas/api/test.php` in browser
3. **Check permissions**: Ensure uploads folder exists and is writable
4. **Restart Flutter**: Stop and restart your Flutter app
5. **Try again**: Attempt the image upload

## If Still Not Working

1. Check Windows Firewall settings
2. Verify no other service is using port 80
3. Try a different port (change Apache to port 8080)
4. Check if antivirus is blocking localhost connections

## Debug Information Added
The upload script now logs detailed information to help identify where the process is failing.
