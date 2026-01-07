# Profile Image Upload Feature

## Overview
This feature allows users to upload and update their profile pictures in the Flutter app.

## Setup Instructions

### 1. Database Setup
Run the SQL script to add the profile_image column to the users table:
```sql
-- Run add_profile_image_column.sql in your MySQL database
```

### 2. Backend Setup
- The `upload_profile_image.php` script handles image uploads
- Images are stored in the `api/uploads/` directory
- Make sure the uploads directory has proper write permissions

### 3. Flutter Dependencies
The following dependencies have been added to `pubspec.yaml`:
- `image_picker: ^1.1.2` - For selecting images from gallery

## How It Works

1. **User taps on profile avatar** - Opens the image picker
2. **Image selection** - User can select an image from their gallery
3. **Image upload** - Selected image is uploaded to the server
4. **Database update** - The filename is saved in the users table
5. **UI update** - The profile image is displayed in the app

## File Structure

### Backend Files
- `api/upload_profile_image.php` - Handles image upload and database update
- `api/uploads/` - Directory where profile images are stored
- `api/add_profile_image_column.sql` - SQL script to add profile_image column

### Frontend Files
- `lib/pages/profil_page.dart` - Updated with image picker functionality
- `lib/services/api_service.dart` - Added uploadProfileImage method

## Features
- Image validation (JPEG, PNG, GIF only)
- File size limit (5MB max)
- Automatic image resizing (800x800 max, 80% quality)
- Unique filename generation to prevent conflicts
- Error handling with user-friendly messages
- Network image loading for existing profile pictures

## Notes
- Images are accessible via: `http://localhost/praktikmcuas/api/uploads/[filename]`
- The app automatically creates the uploads directory if it doesn't exist
- Profile images are stored with unique names including user ID and timestamp
