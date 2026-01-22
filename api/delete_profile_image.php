<?php
error_reporting(0);
ini_set('display_errors', 0);

require 'config.php';

header('Content-Type: application/json');

$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';

if (empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Get current image path to delete it from server
$stmt_get = mysqli_prepare($conn, "SELECT profile_image FROM users WHERE id = ?");
mysqli_stmt_bind_param($stmt_get, "i", $user_id);
mysqli_stmt_execute($stmt_get);
$result = mysqli_stmt_get_result($stmt_get);
$user = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt_get);

if ($user && !empty($user['profile_image'])) {
    $file_path = '../' . $user['profile_image'];
    if (file_exists($file_path)) {
        unlink($file_path);
    }
}

// Update database
$stmt = mysqli_prepare($conn, "UPDATE users SET profile_image = NULL WHERE id = ?");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Database prepare failed"]);
    exit;
}

mysqli_stmt_bind_param($stmt, "i", $user_id);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Foto profil berhasil dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus foto profil"]);
}

mysqli_stmt_close($stmt);
?>
