<?php
// Enable error reporting but prevent warnings from corrupting JSON output
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Start output buffering to catch any unexpected output
ob_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Function to send JSON response and exit
function sendJsonResponse($data) {
    // Clean any previous output
    if (ob_get_length()) ob_clean();
    echo json_encode($data);
    exit;
}

// Debug: Log incoming request
error_log("Upload request received: " . print_r($_REQUEST, true));
error_log("Files data: " . print_r($_FILES, true));

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'error', 'message' => 'Invalid request method']);
}

// Include database configuration
require_once 'config.php';

// Check database connection
if (!$conn) {
    sendJsonResponse(['status' => 'error', 'message' => 'Database connection failed']);
}

// Get user ID
$user_id = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;

if ($user_id <= 0) {
    sendJsonResponse(['status' => 'error', 'message' => 'Invalid user ID']);
}

// Check if file was uploaded
if (!isset($_FILES['profile_image']) || $_FILES['profile_image']['error'] !== UPLOAD_ERR_OK) {
    sendJsonResponse(['status' => 'error', 'message' => 'No file uploaded or upload error']);
}

$file = $_FILES['profile_image'];

// Validate file
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
$maxFileSize = 5 * 1024 * 1024; // 5MB

// Debug: Log file info
error_log("File info: " . print_r($file, true));

// Check file extension as fallback
$extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
error_log("File extension: " . $extension);

// Validate by extension first (more reliable)
if (!in_array($extension, $allowedExtensions)) {
    sendJsonResponse([
        'status' => 'error', 
        'message' => "Invalid file extension. Allowed: jpg, jpeg, png, gif. Your file: $extension"
    ]);
}

// Then validate MIME type if available
if (function_exists('finfo_open')) {
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $detectedType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);
    error_log("Detected MIME type: " . $detectedType);
    
    // Map common MIME types to our allowed types
    $mimeMap = [
        'image/jpeg' => 'jpeg',
        'image/jpg' => 'jpg', 
        'image/png' => 'png',
        'image/gif' => 'gif'
    ];
    
    $detectedExtension = isset($mimeMap[$detectedType]) ? $mimeMap[$detectedType] : 'unknown';
    
    if (!in_array($detectedExtension, $allowedExtensions)) {
        sendJsonResponse([
            'status' => 'error', 
            'message' => "MIME type mismatch. Expected image file, detected: $detectedType"
        ]);
    }
} else {
    // Fallback to browser-reported type if finfo not available
    $browserType = strtolower($file['type']);
    error_log("Browser reported type: " . $browserType);
    
    // More permissive check for browser-reported types
    if (strpos($browserType, 'image') === false) {
        sendJsonResponse([
            'status' => 'error', 
            'message' => "File does not appear to be an image. Browser reports: $browserType"
        ]);
    }
}

if ($file['size'] > $maxFileSize) {
    sendJsonResponse(['status' => 'error', 'message' => 'File size too large. Maximum 5MB allowed']);
}

// Create uploads directory if it doesn't exist
$uploadDir = '../uploads/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Generate unique filename
$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$filename = 'profile_' . $user_id . '_' . time() . '.' . $extension;
$uploadPath = $uploadDir . $filename;

// Move uploaded file
if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
    sendJsonResponse(['status' => 'error', 'message' => 'Failed to upload file']);
}

// Update database
$stmt = $conn->prepare("UPDATE users SET profile_image = ? WHERE id = ?");
if ($stmt === false) {
    sendJsonResponse(['status' => 'error', 'message' => 'Database prepare failed: ' . $conn->error]);
}

$stmt->bind_param("si", $filename, $user_id);

if ($stmt->execute()) {
    sendJsonResponse([
        'status' => 'success',
        'message' => 'Profile image uploaded successfully',
        'image_url' => $filename
    ]);
} else {
    sendJsonResponse(['status' => 'error', 'message' => 'Failed to update database: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
