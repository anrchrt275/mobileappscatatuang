<?php
// Script to proxy images with proper CORS headers for Flutter Web
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$file = isset($_GET['file']) ? $_GET['file'] : '';

if (empty($file)) {
    header("HTTP/1.1 400 Bad Request");
    exit("File parameter is missing");
}

// Security: Prevent directory traversal
$filename = basename($file);
$filePath = '../uploads/' . $filename;

if (file_exists($filePath)) {
    $mime = mime_content_type($filePath);
    header("Content-Type: $mime");
    header("Content-Length: " . filesize($filePath));
    readfile($filePath);
} else {
    header("HTTP/1.1 404 Not Found");
    exit("Image not found: " . $filename);
}
?>
