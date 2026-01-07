<?php
// Test script to verify database setup
require_once 'config.php';

echo "<h2>Database Connection Test</h2>";

if (!$conn) {
    echo "<p style='color: red;'>Database connection failed</p>";
    exit;
}

echo "<p style='color: green;'>Database connection successful</p>";

// Check if profile_image column exists
$result = $conn->query("DESCRIBE users");
$hasProfileImage = false;

while ($row = $result->fetch_assoc()) {
    if ($row['Field'] === 'profile_image') {
        $hasProfileImage = true;
        break;
    }
}

if ($hasProfileImage) {
    echo "<p style='color: green;'>profile_image column exists</p>";
} else {
    echo "<p style='color: red;'>profile_image column does not exist</p>";
    echo "<p>Adding profile_image column...</p>";
    
    $sql = "ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL AFTER email";
    if ($conn->query($sql)) {
        echo "<p style='color: green;'>profile_image column added successfully</p>";
    } else {
        echo "<p style='color: red;'>Failed to add profile_image column: " . $conn->error . "</p>";
    }
}

// Check uploads directory
$uploadDir = '../uploads/';
if (!file_exists($uploadDir)) {
    echo "<p style='color: orange;'>Creating uploads directory...</p>";
    if (mkdir($uploadDir, 0777, true)) {
        echo "<p style='color: green;'>Uploads directory created</p>";
    } else {
        echo "<p style='color: red;'>Failed to create uploads directory</p>";
    }
} else {
    echo "<p style='color: green;'>Uploads directory exists</p>";
}

echo "<h2>Setup Complete</h2>";
echo "<p>You can now test the profile image upload feature.</p>";
?>
